FROM python:3.11-alpine as base
RUN apk add --update --virtual .build-deps \
    build-base \
    postgresql-dev \
    python3-dev \
    libpq

COPY requirements.txt /app/requirements.txt
RUN pip install -r  /app/requirements.txt


FROM python:3.11-alpine as build
RUN apk add libpq
COPY --from=base  /usr/local/lib/python3.11/site-packages/ /usr/local/lib/python3.11/site-packages/ 
COPY --from=base /usr/local/bin/ /usr/local/bin/

COPY . /app
ENV PYTHONUNBUFFERED 1

WORKDIR /app

# RUN THE MIGRATION
RUN python manage.py makemigrations
RUN python manage.py migrate

# RUN collect the static file
RUN python manage.py collectstatic

# Run the test
RUN python manage.py test

# Set super user information
# ENV DJANGO_SUPERUSER_USERNAME=
# ENV DJANGO_SUPERUSER_EMAIL=
# ENV DJANGO_SUPERUSER_PASSWORD=

# RUN python manage.py createsuperuser --noinput

EXPOSE 8000

# https://faun.pub/using-kubernetes-secrets-as-environment-variables-5ea3ef7581ef
