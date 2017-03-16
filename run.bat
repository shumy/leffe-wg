
@ECHO OFF

cd /d %~dp0

set JAVA="java"

REM if JAVA_HOME exists, use it
if exist "%JAVA_HOME%/bin/java" (
  set JAVA="%JAVA_HOME%/bin/java"
) else (
  if exist "%JAVA_HOME%/jre/bin/java" (
    set JAVA="%JAVA_HOME%/jre/bin/java"
  )
)

cd ./build/osgi
%JAVA%  -cp system-libs/org.apache.felix.main-5.4.0.jar org.apache.felix.main.Main  %*
