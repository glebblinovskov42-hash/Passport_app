import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.application import MIMEApplication


def send_archive(to_email, archive_path, smtp_config):
    msg = MIMEMultipart()
    msg['Subject'] = 'Passport Data Archive'
    msg['From'] = smtp_config['from']
    msg['To'] = to_email

    with open(archive_path, 'rb') as f:
        part = MIMEApplication(f.read())
        part.add_header(
            'Content-Disposition',
            'attachment',
            filename=archive_path.split('/')[-1]
        )
        msg.attach(part)

    with smtplib.SMTP(smtp_config['host'], smtp_config['port']) as server:
        server.starttls()
        server.login(smtp_config['from'], smtp_config['password'])
        server.send_message(msg)
