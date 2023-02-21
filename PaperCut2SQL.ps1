# Papercut2SQL - by MicroRed Technology Services

#-------------------S-E-T-T-I-N-G-S-------------------#
$script:sqlSrv   = 'DB_Host'      # SQL Server
$script:sqlDb    = 'DB_Name'      # Database Name
$script:sqlTbl   = 'DB_Table'     # Database Table
$script:sqlUsr   = 'DB_USR'       # Database User
$script:sqlPass  = 'DB_PASS'      # Database Pass
#-----------------------------------------------------#

# Check if PaperCut is installed
$pcutInst = Get-Service -Name PCPrintLogger
$pcutInst = $pcutInst.Status
if(!$pcutInst -OR $pcutInst -ne 'Running'){
    Write-Warning "This script requires PaperCut print logger to be installed and running. https://www.papercut.com/products/free-software/print-logger/"
    PAUSE
    exit    
}

# Check if .NET is installed
$netFramework = Get-WindowsFeature net-framework-45-core
$netFramework = $netFramework.Installed
if($netFramework -ne $true){
    Write-Warning "This script requires the .NET framework to be installed. https://dotnet.microsoft.com/en-us/download"
    PAUSE
    exit
}


# Check if the MySQL connector for .NET is installed
$netSQL = Test-Path "C:\Program Files (x86)\MySQL\MySQL Connector NET 8.0.32\Assemblies\net7.0\MySql.Data.dll"
if($netSQL -ne $true){
    Write-Warning "This script requires the MySQL connector for .NET to be installed. https://dev.mysql.com/downloads/connector/net/"
    PAUSE
    exit
}

# Load the MySQL connector for .NET
[void][system.reflection.Assembly]::LoadFrom("C:\Program Files (x86)\MySQL\MySQL Connector NET 8.0.32\Assemblies\net7.0\MySql.Data.dll")

# Define some logging functions
function connectSQL{
    $script:sqlConn = [MySql.Data.MySqlClient.MySqlConnection]@{ConnectionString="server=$sqlSrv;uid=$sqlUsr;pwd=$sqlPass;database=$sqlDb"}
    $script:sqlConn.Open()
}   
function disconnectSQL{
    $script:sqlConn.Close()
}
function doLog{
    Param($pTime,$pUser,$pPages,$pCopies,$pTotal,$pPrinter,$pName,$pClient,$pPaper,$pDriver,$pHeight,$pWidth,$pDuplex,$pColor,$pSize)
    connectSQL

    $script:SQL = New-Object MySql.Data.MySqlClient.MySqlCommand
    $script:SQL.Connection = $script:sqlConn
    $script:SQL.CommandText = "INSERT INTO $sqlTbl (time, user, pages, copies, total_pages, printer, document_name, client, paper_size, driver, height, width, duplex, color, size) VALUES (""$pTime"",""$pUser"",""$pPages"",""$pCopies"",""$pTotal"",""$pPrinter"",""$pName"",""$pClient"",""$pPaper"",""$pDriver"",""$pHeight"",""$pWidth"",""$pDuplex"",""$pColor"",""$pSize"")"
    $script:SQL.ExecuteNonQuery()

    disconnectSQL
}

# Determine the latest PC daily log, parse it, and set the absolute path.
$csv = gci -Path 'C:\Program Files (x86)\PaperCut Print Logger\logs\csv\daily' | sort LastWriteTime | select -Last 1
$csv = "C:\Program Files (x86)\PaperCut Print Logger\logs\csv\daily\$csv"

# Parse the CSV and convert it to an object
$csvI = Get-Content -LiteralPath $csv | Select-Object -Skip 1 | ConvertFrom-Csv

# Loop through the CSV and add rows to the database
foreach($job in $csvI){
    $pTime = $job.Time
    $pUser = $job.User
    [INT]$pPages = $job.Pages
    [INT]$pCopies = $job.Copies
    $pTotal = $pPages * $pCopies
    $pPrinter = $job.Printer
    $pName = $job.'Document Name'
    $pClient = $job.Client
    $pPaper = $job.'Paper Size'
    $pDriver = $job.Language
    $pHeight = $job.Height
    $pWidth = $job.Width
    $pDuplex = $job.Duplex
        if($pDuplex -eq "NOT DUPLEX"){$pDuplex = 0}
        elseif($pDuplex -eq "DUPLEX"){$pDuplex = 1}
    $pColor = $job.Grayscale
        if($pColor -eq "NOT GRAYSCALE"){$pColor = 1}
        elseif($pColor -eq "GRAYSCALE"){$pColor = 0}
    $pSize = $job.Size

    doLog -pTime $pTime -pUser $pUser -pPages $pPages -pCopies $pCopies -pTotal $pTotal -pPrinter $pPrinter -pName $pName -pClient $pClient -pPaper $pPaper -pDriver $pDriver -pHeight $pHeight -pWidth $pWidth -pDuplex $pDuplex -pColor $pColor -pSize $pSize
}

