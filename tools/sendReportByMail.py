#!/usr/bin/env python
# -*- coding: utf-8 -*

import os
import smtplib
import mimetypes
from email.message import EmailMessage
from zipfile import ZipFile
from zipfile import ZIP_DEFLATED

WORKDIR = '/opt/JSFScan.sh'


def getListOfTxtFilesToSend():
    result = list()
    for fileInDirectory in  os.listdir(path=WORKDIR):
        if fileInDirectory.endswith('.txt'):
            result.append(fileInDirectory)
    return result


def buildReportArchive():
    """ Zip all the *.txt files in 1 file archive.zip"""
    with ZipFile(WORKDIR + 'logs.zip', mode='w', compression=ZIP_DEFLATED) as PJFile:
        for logFile in getListOfTxtFilesToSend():
            if logFile is not None:  # file is None when not found
                print(f'\t Compressing file: {logFile}')
                PJFile.write(logFile)
    return WORKDIR + 'logs.zip'


def buildMail():
    sender = os.environ['USER_EMAIL']
    recipient = os.environ['USER_EMAIL']
    message = EmailMessage()
    message['From'] = sender
    message['To'] = recipient
    message['Subject'] = 'Analyze of target over'
    body = """Hello;
        You can find the html report in attachement."""
    message.set_content(body)
    return message


def sendMail():
    mime_type, _ = mimetypes.guess_type('result.zip')
    mime_type, mime_subtype = mime_type.split('/')
    username = os.environ['USER_EMAIL']
    password = os.environ['USER_PASSWORD']
    message = buildMail()
    with open(buildReportArchive(), 'r') as file:
        try:
            message.add_attachment(file.read(), subtype=mime_subtype, filename='result.zip')
            mail_server = smtplib.SMTP_SSL('smtp.gmail.com')
            mail_server.login(username, password)
            mail_server.send_message(message)
            mail_server.quit()
            return True
        except smtplib.SMTPException as e:
            print(e)
    return False

if __name__ == "__main__":
    sendMail()
