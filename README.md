# principles-of-db-f22
Class Project for Principle of Databases as taught in Fall 2022 by Prof. Julia Stoyanovich

## To Populate the Database
```bash
python3 create-data.py > all.sql
psql -U pa1038 -d pa1038_db -f all.sql
```
