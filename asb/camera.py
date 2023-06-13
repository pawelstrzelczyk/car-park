from picamera2 import Picamera2
import numpy as np
import time
import pytesseract
import sqlite3
from sqlite3 import OperationalError
import datetime
import cv2 as cv
import sys

camera = Picamera2()

argv = sys.argv


def capture():
    camera.start()
    
    while True:
        frame = np.array(camera.capture_image())
        
        gray = cv.cvtColor(frame, cv.COLOR_BGR2GRAY)
        gray = cv.bilateralFilter(gray, 11, 17, 17)
        edged = cv.Canny(gray, 70, 200)

        cv.imwrite('frame.jpg', edged)
    
        (cnts, _) = cv.findContours(edged.copy(), cv.RETR_LIST, cv.CHAIN_APPROX_SIMPLE)
        cnts = sorted(cnts, key=cv.contourArea, reverse=True)[:30]
        
        number_plate_cnt = []
        for c in cnts:
            peri = cv.arcLength(c, True)
            approx = cv.approxPolyDP(c, 0.03 * peri, True)
            if len(approx) == 4:
                number_plate_cnt = approx
                break
        
        mask = np.zeros(gray.shape, np.uint8)
        if len(number_plate_cnt) == 4:
            cv.drawContours(mask, [number_plate_cnt], 0, 255, -1)
        
        new_image = cv.bitwise_and(frame, frame, mask=mask)

        alphanumeric = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        options = "-c tessedit_char_whitelist={}".format(alphanumeric)
        options += " --psm {}".format(7)
        cv.imwrite('ocr.jpg', new_image)

        text = pytesseract.image_to_string(new_image, config=options)
        text = text.strip()
        print(text)

        time.sleep(0.3)
        if len(text) == 7:
            try:
                db = sqlite3.connect('parking.db', timeout=20)
                cursor = db.cursor()
                if argv[1] == "ENTRY":
                    cursor.execute("SELECT license_plate_number FROM ENTRIES WHERE license_plate_number = ? and exit_timestamp=0", (text, ))
                    if(len(cursor.fetchall())==0):
                        db.cursor().execute("INSERT INTO ENTRIES(license_plate_number, entry_timestamp, exit_timestamp, paid) VALUES(?, ?, ?, ?)",
                                        ("PO123AZ", datetime.datetime.now().isoformat(), 0, 0))                            
                elif argv[1] == "EXIT":
                    db.cursor().execute(
                        "UPDATE ENTRIES SET exit_timestamp = ? WHERE license_plate_number = ? and exit_timestamp = 0",
                        (datetime.datetime.now().isoformat(), text)
                        )

            except OperationalError:
                return ""
            db.commit()
            db.close()

        
if __name__ == "__main__":
    capture()

        
