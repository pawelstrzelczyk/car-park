import RPi.GPIO as GPIO
import time
import sqlite3

GPIO.setmode(GPIO.BCM)
GPIO_TRIGGER = 20
GPIO.setup(GPIO_TRIGGER, GPIO.IN)


def gasCheck():
    while True:
        time.sleep(2)
        gas_input = GPIO.input(GPIO_TRIGGER)
        if not gas_input:
            db = sqlite3.connect('parking.db', timeout=20)
            db.cursor().execute("INSERT INTO GAS_ALERTS DEFAULT VALUES")
            db.commit()
            db.close()
            time.sleep(2)


if __name__ == "__main__":
    try:
        gasCheck()
        print('dupa')
    except KeyboardInterrupt:
        print("Measurement stopped by user")