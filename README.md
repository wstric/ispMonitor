# Multi-network ISP monitor
Detects and reports outages of internet service. 
I'm running this on a linux box connected to each of the networks I'm testing in parallel.
This is pretty ugly but it gives me something to complain to my ISP about.

## Configuration
 - use `ip -a link` to determine interfaces and their order
 - populate in desired order in `config_interfaces`
 - make sure `config_ping` and `config_curl` are populated with endpoints
 - initialize kickstart files by creating copy
```bash
cp isp_mon_collate_last.log.kickstart isp_mon_collate_last.log
cp isp_mon_outages.csv.kickstart isp_mon_outages.csv
```
 - update `isp_mon_outages.csv` csv column headers if needed
 - update directory paths in `ispMonMain.service` and `ispMonCollate.service` if needed
 - update schedule interval in `ispMonMain.timer` and `ispMonCollate.timer` if needed

    
## Installation
 - copy application files to working directory on host system
 - make sure all scripts are executable, update if not
```bash
chmod +x isp_mon_main.sh
chmod +x isp_mon_ping.sh
chmod +x isp_mon_curl.sh
chmod +x isp_mon_collate.sh
```
 - perform configuration on application files
 - move systemd service and timers to system folders
```bash
sudo mv ispMonMain.service /etc/systemd/system/ispMonMain.service
sudo mv ispMonMain.timer /etc/systemd/system/ispMonMain.timer
sudo mv ispMonCollate.service /etc/systemd/system/ispMonCollate.service
sudo mv ispMonCollate.timer /etc/systemd/system/ispMonCollate.timer
```
 - enable and start the task timers in systemd
```bash
sudo systemctl enable ispMonMain.timer
sudo systemctl start ispMonMain.timer
sudo systemctl enable ispMonCollate.timer
sudo systemctl start ispMonCollate.timer
``` 
