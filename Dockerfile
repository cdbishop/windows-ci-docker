# escape=`

# Copyright (C) Microsoft Corporation. All rights reserved.
# Licensed under the MIT license. See LICENSE.txt in the project root for license information.

# Windows server 2019 (AWS)
ARG FROM_IMAGE=mcr.microsoft.com/windows:10.0.17763.1039

# Windows Home (for testing)
#ARG FROM_IMAGE=microsoft/dotnet-framework:3.5-sdk-windowsservercore-1709

FROM ${FROM_IMAGE}

# Reset the shell.
SHELL ["cmd", "/S", "/C"]

# Set up environment to collect install errors.
COPY Install.cmd C:\TEMP\
ADD https://aka.ms/vscollect.exe C:\TEMP\collect.exe

# Install Node.js LTS
ADD https://nodejs.org/dist/v12.18.2/node-v12.18.2-x64.msi C:\TEMP\node-install.msi
RUN start /wait msiexec.exe /i C:\TEMP\node-install.msi /l*vx "%TEMP%\MSI-node-install.log" /qn ADDLOCAL=ALL

# Install Yarn
ADD https://classic.yarnpkg.com/latest.msi C:\TEMP\yarn.msi
RUN start /wait msiexec.exe /i C:\TEMP\yarn.msi /l*vx "%TEMP%\MSI-yarn-install.log" /qn ADDLOCAL=ALL

# yarn dependencies
RUN yarn global add parcel-bundler

# Download channel for fixed install.
ARG CHANNEL_URL=https://aka.ms/vs/15/release/channel
ADD ${CHANNEL_URL} C:\TEMP\VisualStudio.chman

# Download and install Build Tools for Visual Studio 2017 for native desktop workload.
ADD https://aka.ms/vs/15/release/vs_buildtools.exe C:\TEMP\vs_buildtools.exe
RUN C:\TEMP\Install.cmd C:\TEMP\vs_buildtools.exe --quiet --wait --norestart --nocache `
    --channelUri C:\TEMP\VisualStudio.chman `
    --installChannelUri C:\TEMP\VisualStudio.chman `
    --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended`
    --installPath C:\BuildTools

ADD https://www.python.org/ftp/python/3.7.3/python-3.7.3.exe C:\TEMP\python-3.7.3.exe
RUN powershell.exe -Command "Start-Process C:\TEMP\python-3.7.3.exe -ArgumentList '/quiet InstallAllUsers=1 PrependPath=1' -Wait ;"

ADD https://github.com/git-for-windows/git/releases/download/v2.12.2.windows.2/MinGit-2.12.2.2-64-bit.zip C:\TEMP\MinGit.zip
RUN powershell.exe -Command "Expand-Archive c:\TEMP\MinGit.zip -DestinationPath c:\MinGit; `
    $env:PATH = $env:PATH + ';C:\MinGit\cmd\;C:\MinGit\cmd'; `
    [Environment]::SetEnvironmentVariable(\"Path\", $env:Path + ';C:\MinGit\cmd\;C:\MinGit\cmd', [EnvironmentVariableTarget]::Machine);"

# pip dependencies
RUN pip install --upgrade `
    conan==1.11.2 `
    pystache `
    scp `
    paramiko `
    requests `
    git+https://github.com/vcatechnology/colorama@0.4.1-1 `
    junitparser

ADD https://github.com/wixtoolset/wix3/releases/download/wix3112rtm/wix311-binaries.zip C:\TEMP\wix.zip
RUN powershell.exe -Command "Expand-Archive c:\TEMP\wix.zip -DestinationPath c:\Wix; `
    $env:PATH = $env:PATH + ';C:\Wix\;'; `
    [Environment]::SetEnvironmentVariable(\"Path\", $env:Path + ';C:\Wix\;', [EnvironmentVariableTarget]::Machine);"

# Use developer command prompt and start PowerShell if no other command specified.
ENTRYPOINT ["C:\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "&&", "powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]
