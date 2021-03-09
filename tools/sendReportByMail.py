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
    return WORKDIR + 'result.zip'


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
        message.add_attachment(file.read(), subtype=mime_subtype, filename='urls.txt')
        mail_server = smtplib.SMTP_SSL('smtp.gmail.com')
        mail_server.login(username, password)
        retour_mail = mail_server.send_message(message)
        print(f'Server SMTP result status : {retour_mail}')
        mail_server.quit()
        print('(DEBUG) Sending report to the user by mail: OK')
        exit(0)
    print('(DEBUG) Sending report to the user by mail: KO')
    exit(-1)


if __name__ == "__main__":
    sendMail()
