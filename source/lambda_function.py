import json
import os
import boto3
from boto3.dynamodb.conditions import Key
import time

import requests
import pandas as pd
import matplotlib.pyplot as plt

token         = os.environ['telegram_token']
serial_number = os.environ['serial_number']
table_name    = os.environ['table_name']
thing_name    = os.environ['thing_name']
shadow_name   = os.environ['shadow_name']

singlecommands = ["/start", "/help", "/getmetrics"]
switchcommands = ["/light", "/waterpump", "/ventilation"]
numbercommands = ["/temperaturelimit", "/lightlimit", "/humiditylimit", "/moisturelimit", "/getgraph"]
authorisedid   = os.environ['authorisedid']



def start(chat_id):
    text = """
Hi, I'm GrootBot, bot created to help you with your IoT devices.
Especially gardening one ;) Please type /help to see my commands.
If you have any more questions go ahead and ask my creator.
Created by Borys Levkovych @CallMeBober.
    """
    send_message(text, chat_id)
    
def help(chat_id):
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
    
def getmetrics(chat_id):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name)
    kce = Key('SerialNumber').eq(serial_number) & Key('Timestamp').between(0, round(time.time()))
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

def getgraph(hours, chat_id):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name)
    kce = Key('SerialNumber').eq(serial_number) & Key('Timestamp').between(round(time.time() - int(hours) * 3600), round(time.time()))
    response = table.query(
        KeyConditionExpression=kce, 
        ScanIndexForward = False, 
    )
    items = response['Items']

    df = pd.read_json(json.dumps(items, ensure_ascii=False, default=str))
    try: 
        df.plot(x="Timestamp", y=["Light", "Temperature", "Humidity", "Moisture"]).set_xlabel("Time")
        plt.savefig('/tmp/graph.jpg')
        send_photo(chat_id)
    except:
        send_message("There is no data from sensors for that period of time", chat_id)
    
def change_thing(thing, argument, chat_id):
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
    client = boto3.client('iot-data')
    response = client.get_thing_shadow(
        thingName=thing_name,
        shadowName=shadow_name
    )
    payload = json.loads(response["payload"].read())
 
    return(payload)  
    
def update_shadow(thing, argument):
    payload = {
          'state': {
              'desired': {
                  thing : argument
              }
          }
      }
    client = boto3.client('iot-data')
    client.update_thing_shadow(
        thingName=thing_name,
        shadowName=shadow_name,
        payload=json.dumps(payload)
    )

def send_message(text, chat_id):
    endpoint = "https://api.telegram.org/bot" + token + "/sendMessage"
    payload = {
        "chat_id": chat_id,
        "text": text
    }
    requests.post(endpoint, data=payload)
    
def send_photo(chat_id):    
    endpoint = "https://api.telegram.org/bot" + token + "/sendPhoto"
    payload = {
        "chat_id": chat_id
    }
    with open('/tmp/graph.jpg', "rb") as image_file:
        ret = requests.post(endpoint, data=payload, files={"photo": image_file})
    return ret.json()
    
def check_command(message, chat_id):   
    command = message[0]
    if command in singlecommands:
        if len(message) == 1:
            eval(command[1:])(chat_id)
        else:
            send_message("This command does not require arguments", chat_id)
            
    elif command in switchcommands:
        if len(message) == 2:
            argument  = message[1]
            if argument == "on" or argument == "off":
                change_thing(command[1:], argument, chat_id)
            else:
                send_message("The arguments should be \"on\" or \"off\"", chat_id)
        else:
            send_message("This command requires one argument", chat_id)
            
    elif command in numbercommands:
        if len(message) == 2:
            argument  = message[1]
            if argument.isnumeric():
                if command == "/getgraph":
                    eval(command[1:])(argument, chat_id)
                else:
                    change_thing(command[1:], argument, chat_id)
            else:
                send_message("The command can only use natural numbers as arguments", chat_id)
        else:
            send_message("This command requires one argument", chat_id)
    else:
        send_message("The command: \"" + command + "\" is unknown. Try /help", chat_id)

def lambda_handler(event, context):
    request_body = json.loads(event['body'])
    try:
        chat_id  = request_body['message']['chat']['id']
        id       = request_body['message']['from']['id']
        message  = request_body['message']['text'].split()
    except: 
        return {
            'statusCode': 200
        }
        
    if str(id) in authorisedid:
        check_command(message, chat_id)
    else:
        send_message("You are not authorised to use this bot contact @CallMeBober for more information", chat_id)
        
    return {
        'statusCode': 200
    }