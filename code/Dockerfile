FROM python:3.8-alpine
RUN mkdir /app
ADD . /app
WORKDIR /app
COPY src/ /app
RUN pip install -r requirements.txt
CMD ["python", "ATC_web.py"]