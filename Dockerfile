FROM python:3.8
RUN mkdir /app/
WORKDIR /app
COPY requirements.txt /app/
RUN pip install -r requirements.txt
COPY ./webapp /app/
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
