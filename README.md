# PaperCut2SQL
Parse and send PaperCut print logs to a MySQL database.

## How to use:
This script should be scheduled to run once a day after all print jobs for the day are completed. It will look in the PaperCut daily logs directory, pick the latest file, then parse and log it to a MySQL database.

## Prerequisites:
* MySQL Server
* Windows Server with print server role
* [PaperCut Print Logger](https://www.papercut.com/products/free-software/print-logger/)
* [.NET 7](https://dotnet.microsoft.com/en-us/download)
  * [Direct link to download](https://dotnet.microsoft.com/en-us/download/dotnet/thank-you/sdk-7.0.200-windows-x64-installer)
* [.NET MySQL Connector (8.0.32)](https://dev.mysql.com/downloads/connector/net/)
  * [Direct link to download](https://dev.mysql.com/get/Downloads/Connector-Net/mysql-connector-net-8.0.32.msi)
