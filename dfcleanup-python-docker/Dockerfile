FROM python:3

# Copying over requirements.txt
ADD requirements.txt .

# Installing required dependencies in requirements.txt
RUN pip install -r requirements.txt

# Copying over my_modules.py
ADD my_modules.py .

# Copying over df_cleanup.py 
ADD df_cleanup.py .

# Executing script
CMD [ "python3", "./df_cleanup.py" ] 

