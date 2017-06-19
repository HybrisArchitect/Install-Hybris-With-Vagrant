#!/usr/bin/env bash

HYBRISDIR="/opt/hybris63" 
MYSQLDIR="/opt/mysql57"
HYBRISDB="hybrisDB"
HYBRISDBUSERNAME=root
HYBRISDBPASSWORD=Passw0rd!

yum update -y

echo "Installing wget.."
yum install wget -y

echo "Installing Java 8.."
cd /opt/
wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz"
tar xzf jdk-8u131-linux-x64.tar.gz
cd /opt/jdk1.8.0_131/
alternatives --install /usr/bin/java java /opt/jdk1.8.0_131/bin/java 2

alternatives --install /usr/bin/jar jar /opt/jdk1.8.0_131/bin/jar 2
alternatives --install /usr/bin/javac javac /opt/jdk1.8.0_131/bin/javac 2
alternatives --set jar /opt/jdk1.8.0_131/bin/jar
alternatives --set javac /opt/jdk1.8.0_131/bin/javac

echo "Java Version: "
java -version
echo "Setting JAVA_HOME Variable.."
export JAVA_HOME=/opt/jdk1.8.0_131

echo "Settting JRE_HOME Variable..."
export JRE_HOME=/opt/jdk1.8.0_131/jre

echo "Setting PATH Variable"..
export PATH=$PATH:/opt/jdk1.8.0_131/bin:/opt/jdk1.8.0_131/jre/bin

echo "Installing MySQL.."
mkdir $MYSQLDIR
cd MYSQLDIR
wget https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
yum -y localinstall mysql57-community-release-el7-11.noarch.rpm
echo "Verifying MySQL Installation..."
yum repolist enabled | grep "mysql.*-community.*"
yum -y install mysql-server

echo "Starting the MySQL daemon........................................"
service mysqld start
service mysqld status
echo "Changing the MySQL password..."
MYSQL_TEMP_PWD=`cat /var/log/mysqld.log | grep 'A temporary password is generated' | awk -F'root@localhost: ' '{print $2}'`
echo "Original Mysql Password: " 
echo $MYSQL_TEMP_PWD
echo "Setting Hybris Password..."

mysqladmin -u root -p`echo $MYSQL_TEMP_PWD` password $HYBRISDBPASSWORD
mysql -uroot -p$HYBRISDBPASSWORD -e "CREATE DATABASE $HYBRISDB;"
mysql -uroot -p$HYBRISDBPASSWORD -e 'Show Databases;'

echo "Copying the Hybris installatiion from from host to guest machine.."

echo "Creating Hybris home directory..."
mkdir $HYBRISDIR
cd $HYBRISDIR
cp /vagrant/hybris-commerce-suite-6.3.0.1.zip $HYBRISDIR/
echo "Installing Unzip..."
yum -y install unzip

echo "Unzipping the Hybris Installation.."
unzip hybris-commerce-suite-6.3.0.1.zip

echo "Removing the Hybris Installation zip file.."
rm hybris-commerce-suite-6.3.0.1.zip
echo "Changing into the bin/platform directory..."
cd $HYBRISDIR/hybris/bin/platform


echo "Update the project.properties file to use mysql and our credentials..."

sed -i '247s/db.url=jdbc:hsqldb:file/#db.url=jdbc:hsqldb:file/' project.properties
sed -i '248s/db.driver=org.hsqldb.jdbcDriver/#db.driver=org.hsqldb.jdbcDriver/' project.properties
sed -i '249s/db.username=sa/#db.username=sa/' project.properties
sed -i '250s/db.password=/#db.password=/' project.properties
sed -i '251s/db.tableprefix=/#db.tableprefix=/' project.properties
sed -i '252s/hsqldb.usecachedtables=true/#hsqldb.usecachedtables=true/' project.properties

sed -i '280s/#db/db/' project.properties
sed -i "280s/<dbname>/$HYBRISDB/" project.properties
sed -i '281s/#db/db/' project.properties
sed -i '282s/#db/db/' project.properties 
sed -i "282s/<username>/$HYBRISDBUSERNAME/" project.properties 
sed -i '283s/#db/db/' project.properties
sed -i "283s/<password>/$HYBRISDBPASSWORD/" project.properties 
sed -i '284s/#db/db/' project.properties
sed -i '285s/#mysql/mysql/' project.properties
sed -i '286s/#mysql/mysql/' project.properties

echo "Downloading and installing the MySQL Driver.."
cd $HYBRISDIR/hybris/bin/platform/lib/dbdriver
wget https://github.com/HybrisArchitect/MySQL-Connector-Java-Download/raw/master/mysql-connector-java-5.1.23-bin.jar

cd $HYBRISDIR/hybris/bin/platform
. ./setantenv.sh

echo "Performing Ant Clean All..	"
ant clean all -Dinput.template=develop
echo "Starting the Hybris Server.."
./hybrisserver.sh

