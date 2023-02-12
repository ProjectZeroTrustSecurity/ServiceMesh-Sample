FROM python:alpine
RUN mkdir /app
WORKDIR /app

COPY requirements.txt /app
RUN pip install --no-cache-dir -r /app/requirements.txt

COPY app.py /app/

EXPOSE 8080
CMD [ "python", "./app.py" ]
