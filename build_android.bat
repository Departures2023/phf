@echo off
set JAVA_HOME=C:\Program Files\Java\jdk-24
set PATH=%JAVA_HOME%\bin;%PATH%
cd /d "%~dp0"
flutter build apk --debug
