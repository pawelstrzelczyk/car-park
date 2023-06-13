from picamera2 import Picamera2
import cv2 as cv
import numpy as np
import sqlite3
from sqlite3 import OperationalError
import datetime
from math import ceil

def calculate_fee(entry_timestamp: datetime.datetime, now: datetime.datetime) -> float:

    time = now - entry_timestamp

    time_in_minutes = ceil(time.total_seconds() / 60)

    if time_in_minutes <= 15:
        fee = 0
    else:
        fee = ceil(time_in_minutes / 60) * 5 #PLN

    return fee



def scan_QR():
    camera = Picamera2()
    camera.create_still_configuration()
    camera.start()
    scanned = False
    while not scanned:
        image = camera.capture_image()
        qcd = cv.QRCodeDetector()
        decoded_info, _, _ = qcd.detectAndDecode(np.array(image)[:, :, ::-1].copy())
        if len(decoded_info) == 7:
            scanned = True
            db = sqlite3.connect('parking.db', timeout=20)
            cursor = db.cursor()
            try:
                cursor.execute(
                    "SELECT license_plate_number, entry_timestamp from ENTRIES WHERE license_plate_number = (?) AND exit_timestamp = 0",
                    (decoded_info,)
                )
                fee = 0.0
                for row in cursor:
                    print(row[0])
                    fee = calculate_fee(entry_timestamp=datetime.datetime.fromisoformat(row[1]), now=datetime.datetime.now()+datetime.timedelta(hours=5))
                
                db.commit()
                print(fee)

                cursor.execute(
                    "UPDATE ENTRIES SET paid = 1, fee = ? WHERE license_plate_number = ? and exit_timestamp = 0",
                    (fee, decoded_info),
                )

                db.commit()

            except OperationalError:
                print("Licence plate read error")

            db.close()


if __name__ == "__main__":
    scan_QR()