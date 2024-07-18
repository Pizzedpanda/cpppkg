/**
 * DHT11.cpp
 * Library for reading temperature and humidity from the DHT11 sensor.
 *
 * Author: Dhruba Saha
 * Version: 2.1.0
 * License: MIT
 */

#include "pico/DHT11.h"

/**
 * Constructor for the DHT11 class.
 * Initializes the pin to be used for communication and sets it to output mode.
 *
 * @param pin: Digital pin number on the Pico board to which the DHT11 sensor is connected.
 */
DHT11::DHT11(int pin) : _pin(pin)
{
  gpio_init(_pin);
  gpio_set_dir(_pin, GPIO_OUT);
  gpio_put(_pin, 1);
}

/**
 * Sets the delay between consecutive sensor readings.
 * If this method is not called, a default delay of 500 milliseconds is used.
 *
 * @param delay: Delay duration in milliseconds between sensor readings.
 */
void DHT11::setDelay(uint32_t delay)
{
  _delayMS = delay;
}

/**
 * Reads raw data from the DHT11 sensor.
 * This method handles the direct communication with the DHT11 sensor and retrieves the raw data.
 * It's used internally by the readTemperature, readHumidity, and readTemperatureHumidity methods.
 *
 * @param data: An array of bytes where the raw sensor data will be stored.
 *              The array must be at least 5 bytes long, as the DHT11 sensor returns 5 bytes of data.
 * @return: Returns 0 if the data is read successfully and the checksum matches.
 *          Returns DHT11::ERROR_TIMEOUT if the sensor does not respond or communication times out.
 *          Returns DHT11::ERROR_CHECKSUM if the data is read but the checksum does not match.
 */
int DHT11::readRawData(uint8_t data[5])
{
  sleep_ms(_delayMS);
  startSignal();
  absolute_time_t timeout_start = get_absolute_time();

  while (gpio_get(_pin) == 1)
  {
    if (absolute_time_diff_us(timeout_start, get_absolute_time()) > TIMEOUT_DURATION * 1000)
    {
      return DHT11::ERROR_TIMEOUT;
    }
  }

  if (gpio_get(_pin) == 0)
  {
    sleep_us(80);
    if (gpio_get(_pin) == 1)
    {
      sleep_us(80);
      for (int i = 0; i < 5; i++)
      {
        data[i] = readByte();
        if (data[i] == DHT11::ERROR_TIMEOUT)
        {
          return DHT11::ERROR_TIMEOUT;
        }
      }

      if (data[4] == ((data[0] + data[1] + data[2] + data[3]) & 0xFF))
      {
        return 0; // Success
      }
      else
      {
        return DHT11::ERROR_CHECKSUM;
      }
    }
  }
  return DHT11::ERROR_TIMEOUT;
}

/**
 * Reads a byte of data from the DHT11 sensor during the communication process.
 *
 * @return: A byte of data read from the sensor.
 */
uint8_t DHT11::readByte()
{
  uint8_t value = 0;

  for (int i = 0; i < 8; i++)
  {
    while (gpio_get(_pin) == 0);
    sleep_us(30);
    if (gpio_get(_pin) == 1)
    {
      value |= (1 << (7 - i));
    }
    while (gpio_get(_pin) == 1);
  }
  return value;
}

/**
 * Sends a start signal to the DHT11 sensor to initiate a data read.
 * This involves setting the data pin low for a specific duration, then high,
 * and finally setting it to input mode to read the data.
 */
void DHT11::startSignal()
{
  gpio_set_dir(_pin, GPIO_OUT);
  gpio_put(_pin, 0);
  sleep_ms(18);
  gpio_put(_pin, 1);
  sleep_us(40);
  gpio_set_dir(_pin, GPIO_IN);
}

/**
 * Reads and returns the temperature from the DHT11 sensor.
 * Utilizes the readRawData method to retrieve raw data from the sensor and then extracts
 * the temperature from the data array.
 *
 * @return: Temperature value in Celsius. Returns DHT11::ERROR_TIMEOUT if reading times out,
 *          or DHT11::ERROR_CHECKSUM if checksum validation fails.
 */
int DHT11::readTemperature()
{
  uint8_t data[5];
  int error = readRawData(data);
  if (error != 0)
  {
    return error;
  }
  return data[2];
}

/**
 * Reads and returns the humidity from the DHT11 sensor.
 * Utilizes the readRawData method to retrieve raw data from the sensor and then extracts
 * the humidity from the data array.
 *
 * @return: Humidity value in percentage. Returns DHT11::ERROR_TIMEOUT if reading times out,
 *          or DHT11::ERROR_CHECKSUM if checksum validation fails.
 */
int DHT11::readHumidity()
{
  uint8_t data[5];
  int error = readRawData(data);
  if (error != 0)
  {
    return error;
  }
  return data[0];
}

/**
 * Reads and returns the temperature and humidity from the DHT11 sensor.
 * Utilizes the readRawData method to retrieve raw data from the sensor and then extracts
 * both temperature and humidity from the data array.
 *
 * @param temperature: Reference to a variable where the temperature value will be stored.
 * @param humidity: Reference to a variable where the humidity value will be stored.
 * @return: An integer representing the status of the read operation.
 *          Returns 0 if the reading is successful, DHT11::ERROR_TIMEOUT if a timeout occurs,
 *          or DHT11::ERROR_CHECKSUM if a checksum error occurs.
 */
bool DHT11::readTemperatureHumidity(int &temperature, int &humidity)
{
  uint8_t data[5];
  int error = readRawData(data);
  if (error != 0)
  {
    return error;
  }
  humidity = data[0];
  temperature = data[2];
  return 0; // Indicate success
}

/**
 * Returns a human-readable error message based on the provided error code.
 * This method facilitates easier debugging and user feedback by translating
 * numeric error codes into descriptive strings.
 *
 * @param errorCode The error code for which the description is required.
 * @return A descriptive string explaining the error.
 */
const char* DHT11::getErrorString(int errorCode)
{
  switch (errorCode)
  {
  case DHT11::ERROR_TIMEOUT:
    return "Error 253 Reading from DHT11 timed out.";
  case DHT11::ERROR_CHECKSUM:
    return "Error 254 Checksum mismatch while reading from DHT11.";
  default:
    return "Error Unknown.";
  }
}
