FROM tomcat:7-jre8
ARG contversion
RUN wget -P /usr/local/tomcat/webapps http://172.20.20.50:8081/nexus/content/repositories/releases/training/task4/${contversion}/task4.war
