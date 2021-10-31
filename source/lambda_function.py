'''Main module.'''

import json
import os
import time

import boto3
from boto3.dynamodb.conditions import Key

import requests
import pandas
import matplotlib.pyplot as plt

TELEGRAM_TOKEN = os.environ['telegram_token']
SERIAL_NUMBER  = os.environ['serial_number']
TABLE_NAME     = os.environ['table_name']
THING_NAME     = os.environ['thing_name']
SHADOW_NAME    = os.environ['shadow_name']
AUTHORIZED_IDS = os.environ['authorised_ids']

simple_commands = ["/start", "/help", "/getmetrics"]
switch_commands = ["/light", "/waterpump", "/ventilation"]
value_commands  = ["/temperaturelimit", "/lightlimit", "/humiditylimit", "/moisturelimit", "/getgraph"]



def start_command(chat_id):
    '''Contains /start message'''
    text = """
Hi, I'm GrootBot, bot created to help you with your IoT devices.
Especially gardening one ;) Please type /help to see my commands.
If you have any more questions go ahead and ask my creator.
Created by Borys Levkovych @CallMeBober.
    """
    send_message(text, chat_id)

def help_command(chat_id):
    '''Contains /help message'''
    text = """
/getmetrics - get data from greenhouse's sensors
/getgraph      [hours] - get visual data for period of time
/light               [on/off] - turn on/off the light in the greenhouse
/waterpump [on/off] - turn on/off the waterpump in the greenhouse
/ventilation   [on/off] - turn on/off the vent in the greenhouse
/temperaturelimit [number] - set the limit for temperature
/lightlimit                 [number] - set the limit for light
/moisturelimit        [number] - set the limit for moisture (ground)
/humiditylimit         [number] - set the limit for humidity (air)
(exceeding/falling behind which will result in vent/light/waterpump turning on/off)
    """
    send_message(text, chat_id)

def get_metrics(chat_id):
    '''Query DynamoDB for the last data that was received'''
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(TABLE_NAME)
    kce = Key('SerialNumber').eq(SERIAL_NUMBER) & Key('Timestamp').between(0, round(time.time()))
    response = table.query(
        KeyConditionExpression=kce,
        ScanIndexForward = False,
        Limit = 1
    )
    item = response['Items'][0]

    text = f"""
Humidity of the air: {item["Humidity"]} %
Moisture of the ground: {item["Moisture"]} %
Temperature: {item["Temperature"]} °C
Light: {item["Light"]} lx
    """
    send_message(text, chat_id)

def get_graph(hours, chat_id):
    '''Query everything in DynamoDB for a range of time and create a graph from that data'''
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(TABLE_NAME)
    time_range = round(time.time() - int(hours) * 3600)
    kce = Key('SerialNumber').eq(SERIAL_NUMBER) & Key('Timestamp').between(round(time_range), round(time.time()))
    response = table.query(
        KeyConditionExpression=kce,
        ScanIndexForward = False,
    )
    items = response['Items']

    data_frame = pandas.read_json(json.dumps(items, ensure_ascii=False, default=str))
    try:
        data_frame.plot(x="Timestamp", y=["Light", "Temperature", "Humidity", "Moisture"]).set_xlabel("Time")
        plt.savefig('/tmp/graph.jpg')
        send_photo(chat_id)
    except KeyError:
        send_message("There is no data from sensors for that period of time", chat_id)

def change_thing(thing, argument, chat_id):
    '''Compare command to a shadow and change it if required'''
    payload = get_shadow()
    reported_state = payload["state"]["reported"][thing]
    desired_state  = payload["state"]["desired"][thing]

    if reported_state == argument and desired_state == argument:
        if argument.isnumeric():
            send_message("The limit is already set to " + argument, chat_id)
        else:
            send_message("The " + thing + " is already " + argument, chat_id)

    elif reported_state != argument and desired_state == argument:
        if argument.isnumeric():
            send_message("Wait for the thing to update its limit", chat_id)
        else:
            send_message("Wait for the " + thing + " to turn " + argument, chat_id)

    elif reported_state == argument and desired_state != argument:
        update_shadow(thing, argument)
        if argument.isnumeric():
            send_message("The limit is already set to " + argument, chat_id)
        else:
            send_message("The " + thing + " is already " + argument, chat_id)

    else:
        update_shadow(thing, argument)
        if argument.isnumeric():
            send_message("The limit was set to " + argument, chat_id)
        else:
            send_message("The " + thing + " was turned " + argument, chat_id)

def get_shadow():
    '''Recieve shadow from AWS IoT Thing'''
    client = boto3.client('iot-data')
    response = client.get_thing_shadow(
        thingName=THING_NAME,
        shadowName=SHADOW_NAME
    )
    payload = json.loads(response["payload"].read())

    return payload

def update_shadow(thing, argument):
    '''Change shadow for AWS IoT Thing'''
    payload = {
          'state': {
              'desired': {
                  thing : argument
              }
          }
      }
    client = boto3.client('iot-data')
    client.update_thing_shadow(
        thingName=THING_NAME,
        shadowName=SHADOW_NAME,
        payload=json.dumps(payload)
    )

def send_message(text, chat_id):
    '''Send message back in chat'''
    endpoint = "https://api.telegram.org/bot" + TELEGRAM_TOKEN + "/sendMessage"
    payload = {
        "chat_id": chat_id,
        "text": text
    }
    requests.post(endpoint, data=payload)

def send_photo(chat_id):
    '''Send message with a picture'''
    endpoint = "https://api.telegram.org/bot" + TELEGRAM_TOKEN + "/sendPhoto"
    payload = {
        "chat_id": chat_id
    }
    with open('/tmp/graph.jpg', "rb") as image_file:
        ret = requests.post(endpoint, data=payload, files={"photo": image_file})
    return ret.json()

def execute_command(message, chat_id):
    '''Call upon a function based on command name'''
    command = message[0]
    if command == "/start":
        start_command(chat_id)
    elif command == "/help":
        help_command(chat_id)
    elif command == "/getmetrics":
        get_metrics(chat_id)
    elif command == "/getgraph":
        argument = message[1]
        get_graph(argument, chat_id)
    else:
        argument = message[1]
        change_thing(command[1:], argument, chat_id)

def check_arguments(message, chat_id):
    '''Check if arguments are correct'''
    command = message[0]
    if len(message) == 1 and command in simple_commands:
        execute_command(message, chat_id)
    elif len(message) == 2 and command in switch_commands:
        argument = message[1]
        if argument in ("on", "off"):
            execute_command(message, chat_id)
        else:
            send_message("The arguments should be \"on\" or \"off\"", chat_id)
    elif len(message) == 2 and command in value_commands:
        argument = message[1]
        if argument.isnumeric():
            execute_command(message, chat_id)
        else:
            send_message("The command can only use natural numbers as arguments", chat_id)
    else:
        send_message("Invalid arguments. Try /help", chat_id)

def check_command(message, chat_id):
    '''Check if command exists in one of the lists'''
    command = message[0]
    if command in (simple_commands or switch_commands or value_commands):
        check_arguments(message, chat_id)
    else:
        send_message("The command: \"" + command + "\" is unknown. Try /help", chat_id)


def lambda_handler(event, context):
    '''Main handler'''
    request_body = json.loads(event['body'])
    if 'message' in request_body:
        chat_id  = request_body['message']['chat']['id']
        user_id  = request_body['message']['from']['id']
        message  = request_body['message']['text'].split()
    else:
        return {
            'statusCode': 200
    }

    if str(user_id) in AUTHORIZED_IDS:
        check_command(message, chat_id)
    else:
        send_message("You are not authorised to use this bot, contact @CallMeBober for more information", chat_id)

    return {
        'statusCode': 200
    }
