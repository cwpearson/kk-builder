
import os
import re
from pathlib import Path
import mmap
from datetime import datetime

script_dir = Path(os.path.dirname(os.path.realpath(__file__)))
print(f"{script_dir}")

logs_dir = script_dir / "logs"
print(f"{logs_dir}")


records = []

for log_file in logs_dir.glob("**/*.log"):
    m = re.search('([^\/]*)_([0-9]{4})_([0-9]{1,2})_([0-9]{1,2})_(.*).log', str(log_file))
    name = m.group(1)
    year = m.group(2)
    month = m.group(3)
    day = m.group(4)
    kind = m.group(5)

    with open(log_file, "r+") as f:
        start_time = None
        end_time = None
        data = mmap.mmap(f.fileno(), 0)
        fmo = re.search(b"====START==== (.*)", data)
        if fmo:
            ds = fmo.group(1).decode('utf-8')
            start_time = datetime.strptime(ds, '%a %b %d %H:%M:%S %Z %Y')
        fmo = re.search(b"====END==== (.*)", data)
        if fmo:
            ds = fmo.group(1).decode('utf-8')
            end_time = datetime.strptime(ds, '%a %b %d %H:%M:%S %Z %Y')

        if name and year and month and day and kind and start_time and end_time:
            elapsed = end_time - start_time
            print(month, day, year, kind, elapsed)
            tup = (name, month, day, year, kind, elapsed)
            records.append(tup)

print(f"found {len(records)} builds")

records.sort(key=lambda r: r[2])
records.sort(key=lambda r: r[1])
records.sort(key=lambda r: r[3])
records.sort(key=lambda r: r[0])

names = []
for r in records:
    if r[0] not in names:
        names.append(r[0])
names.sort()

dates = []
for r in records:
    date = f"{r[1]}/{r[2]}/{r[3]}"
    if date not in dates:
        dates.append(date)
dates.sort()

for name in names:
    print(f"{name}")
    print(f"date,time")
    for r in [_ for _ in records if _[0] == name]:
        date=f"{r[1]}/{r[2]}/{r[3]}"
        elapsed = r[5]
        print(f"{date},{int(elapsed.total_seconds())}")
    print()

table={}
for r in records:
    name = r[0]
    date = f"{r[1]}/{r[2]}/{r[3]}"
    if date not in table:
        table[date] = {}
    table[date][name] = int(r[5].total_seconds())

print(f"date", end="")
for name in names:
    print(f",{name}", end="")
print()
for date in dates:
    print(date, end="")
    for name in names:
        if date not in table or name not in table[date]:
            print(",", end="")
        else:
            print(f",{table[date][name]}", end="")
    print()        

