---
layout: default
title: Amazon RDS Hands-On Lab 1
---

# Amazon RDS Hands-On Lab 1

## Using Amazon RDS for Applications (1h)

In this lab, we will learn about AWS RDS. First we will launch an EC2 instance with a popular CMS application Wordpress. This will be a self-contained deployment with both Wordpress and MySQL running on the same single server. We will then launch a MySQL server using RDS and re-configure Wordpress to use this RDS MySQL server. Finally, we will re-configure the RDS MySQL server to a higher capacity instance type (vertical scaling) and enable support for High Availability.

### Launch WordPress application

1. Log in to AWS Account and go to EC2 Dashboard. In the top-right corner, ensure that the region name is 'Singapore'. If it is not, click on the region name and select 'Singapore' from the dropdown.
2. Click 'Launch Instance', in left hand menu select 'AWS Marketplace' and search for "Wordpress".
3. Click 'Select' on 'WordPress powered by Bitnami' in the search results.
4. On the popup that appears, ensure that you see 'Free tier eligible' below the WordPress logo. Scroll down to the bottom of the popup and click 'Continue'.
5. When you see 'Step 2: Choose an Instance Type', select 't2.micro' (which should have the green coloured 'Free tier eligible' message under it). Click 'Next: Configure Instance Details' in the bottom right corner of the page.
6. Leave all options to default values and click 'Next: Add Storage'
7. Leave all options to default values and click 'Next: Add Tags'
8. Click 'Add Tag'. Type "Name" in the text box under the 'Key' column. Type "WordpressForRDSLab" in the text box under the 'Value' column. Click 'Next: Configure Security Group'.
9. Leave all options to default values and click 'Review and Launch'. Then click 'Launch' button.
10. In the popup 'Select an existing key pair or create new key pair', click the first drop-down and select 'Create a new key pair'. Type the key pair name 'RDSLabKeyPair'. Then click 'Download Key Pair' button. Save the file in a secure and accessible location. **AWS does not store this file for future retrieval. So, this is the only time that you will be able to download this file.**
11. Click 'Launch Instances' and wait until you see the message 'Your instances are now launching' in green colour. Then scroll down to bottom of the page and click on the 'View Instances' button in bottom-right corner.
12. You will see list of your EC2 instances running in the current region. Find the instance named 'WordpressForRDSLab' and click on it. If you don't see the instance details, look for 3 square icons at bottom-right of the page. Click on the middle one to reveal the instance details pane.
13. The instance will have any automatically assigned public IP address and domain name. The domain name is of the form ec2-XX-XX-XX-XX.<region>.compute.amazonaws.com. It is shown in front of 'Public DNS:'.
14. In a new brower tab, open the domain name of 'WordpressForRDSLab'. You should see the default landing page of WordPress. This confirms that the application has launched successfully.
15. Now let's log in to WordPress as administrator and create some content before migrating the database to AWS RDS.
16. Edit the URL in browser, append "/wp-admin". Alternatively, open a new browser tab, paste the domain name of 'WordpressForRDSLab' and append "/wp-admin". Press enter. You should see WordPress login page.
17. The default username is 'user'. The password was auto-generated when we created the instance. To retrieve the password, go to the list of EC2 instances in AWS Console (it should be already open in another browser tab).
18. With the 'WordpressForRDSLab' instane selected, click 'Actions', click 'Instance Settings' then click 'Get System Log'. You should see a popup with what looks like a Linux bootup log. Scroll down to the bottom and look for a message 'Setting Bitnami application password to '. Copy this password and switch back to the Wordpress login screen.
19. Paste the password and login. In the left hand menu of Wordpress, click on 'Posts > Add New'.
20. Type a post title (e.g. Sample post) and contents, then click 'Publish'.
21. Click the 'View post' link that appears to confirm that the post has been published.
22. Now that we have created some content in our brand new CMS server, let's make sure we will not lose this content. Remember that this CMS server uses a local database which runs on same server as the CMS. To make the deployment more manageable and scalable, let's make some changes.

### Launch MySQL database with AWS RDS

1. Go to the AWS console where you can see your EC2 instances. Click on the 'Services' option at top-left of the page. Type 'RDS' and click to open it in new tab. You can click 'Services' again to close the overlay.
2. Click on 'DB Instances', then click 'Launch DB Instance'.
3. Make sure 'MySQL' is selected, then select 'Dev/Test' at the next step.
4. At step 3, change following options:
	1. Select 'db.t2.micro' for 'DB Instance Class'
	2. Select 'No' for 'Multi-AZ Deployment'
	3. DB Instance Identifier: "wordpressdb"
	4. Master Username: "root"
	5. Master Password & Confirm Password: "admin123"
5. At step 4, change following options:
	1. Database Name: "wordpressdb"
	2. Back Retention Period: 0 days
6. Click 'Launch DB Instance'. When you see the message 'Your DB Instance is being created' in green colour, click 'View Your DB Instance'.
7. Copy the 'Endpoint' to any text editor, we will need it in the next few steps. Make sure that the endpoint is of the form <domain-name>:<port>.

### Backup your WordPress database

1. Go to EC2 dashboard, and in the list of instances, find 'WordpressForRDSLab'. Click on it, then click 'Connect' button at the top. You should see instructions on how to connect to your EC2 instance via an SSH connection.
2. Make sure you have selected 'A standalone SSH client' at the top, then follow the instructions below to log in to your EC2 instance via SSH.
3. Once you have logged in, type the following commands to take backup of the local database of your WordPress CMS.
```
cd apps/wordpress/htdocs/
vi wp-config.php # use any command line text editor you are familiar with
```
4. Scroll down in the text editor to find DB_NAME, DB_USER & DB_PASSWORD. Copy their values to another text editor. We will need these values in next step.
5. Exit the editor that has wp-config.php open, then run following commands in the SSH terminal:
```
cd ~
mysqldump -u <DB_USER> -p<DB_PASSWORD> <DB_NAME> > wordpress.sql
```
6. You might see a mysqldump warning about using password on the command line. You can ignore that for now. Verify that the database was backed up to a file named 'wordpress.sql'.

### Import database backup into RDS

1. Go to EC2 Dashboard on AWS Console, find 'WordpressForRDSLab' and make note of the name of the security group attached to this instance.
2. Go to RDS Dashboard on AWS Console, find 'wordpressdb' in the list, and click on its 'Security Group'. A new browser tab will open showing the security group attached to the RDS database. We need to configure this security group to allow the Wordpress instance to connect to this database.
3. Click on 'Inbound' tab, click 'Edit', then click 'Add Rule'. Select 'Custom TCP' for Type, 3306 for Port and 'Custom' for 'Source'. In front of 'Custom', start typing "sg". From the auto-suggest drop-down, scroll down and select the security group that is attached to the Wordpress EC2 instance. Type "Wordpress CMS running on EC2" as Description and click 'Save' button.
4. Find the RDS database endpoint that you had copied to a text editor earlier. Copy the domain name part of the endpoint (without :PORT), and go back to the SSH terminal that is connected to the EC2 instance.
5. Type the following commands:
```
mysql -u root -padmin123 -h <RDS_ENDPOINT> wordpressdb < wordpress.sql
```
6. We have not imported our backup of local database to RDS database.

### Migrate Wordpress CMS to use RDS database

1. In the SSH terminal connected to Wordpress EC2 instance, type the following commands:
```
cd ~/apps/wordpress/htdocs/
vi wp-config.php # you can use any command line text editor of your choice
```
2. Replace the value of DB_NAME to 'wordpressdb'. This is the name of the database that we have created when we created the RDS instance.
3. Replace the value of DB_USER to 'root' and DB_PASSWORD to 'admin123'
4. Replace the value of DB_HOST to the RDS database endpoint that you have copied to a text editor earlier. The endpoint should have :3306 at the end.
5. Save the file and go to the browser tab that has your Wordpress CMS home page.
6. Reload the page. You should see the 'Sample post' still there.
7. To verify that the database was really changed to RDS, let's create a new post, and see if that is reflected in the RDS database. Go ahead and create a new post in Wordpress. Give it the title 'Second post' and write some content. Publish.
8. Go back to the SSH terminal that is connected to the EC2 instance.
9. Type the commands below to get a dump of RDS database.
```
cd ~
mysqldump -u root -padmin123 -h <RDS_ENDPOINT> wordpressdb > wordpress2.sql
```
10. Open the file 'wordpress2.sql' in a text editor of your choice and search for 'Second post' - the title of our second post that was created after we migrated to RDS. If you find it in the database dump, it means you have successfully migrated your Wordpress CMS to use RDS database!

### Scaling the RDS Database

1. Now let's learn how to scale the database.
2. Go to RDS Dashboard in AWS Console. Select 'wordpressdb' and click 'Instance Actions', then click 'Modify'.
3. Change the 'DB Instance Class' from 'db.t2.micro' to 'db.t2.medium' which has more CPU and RAM resources.
4. Change 'Multi-AZ Deployment' from 'No' to 'Yes'. This will create a synchronous stand-by server in a different Availability Zone (AZ). This makes your database highly available (HA).
5. Scroll down and change 'Backup Retention Period' from '0 days' to '7 days'. This action will enable daily automated backups of your database. The backups are stored in S3.
6. Scroll down to the bottom of the page. Enable 'Apply Immediately', then click 'Continue'. Review the modifications in the next screen, then click 'Modify DB Instance'.
7. Refresh the list of RDS database instances. The Status of 'wordpressdb' will soon change to 'modifying'. When the modifications are complete, the status will go back to 'available'.
8. Some RDS database modifications require database downtime. To learn more, visit this link: http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.DBInstance.Modifying.html

### Triggering database failover from master to standby

1. Go to the RDS Dashboard in AWS Console, and ensure that the 'Multi-AZ' column shows 'Yes' for the 'wordpressdb' database.
2. Now we will use the AWS CLI to force a master database server reboot causing the database to failover to the stand-by. If you do not have AWS CLI installed, use the AWS Console instead.
3. In order to test the availability of our RDS database during this forced failover, we will run a [script]({{ site.baseurl }}{% link scripts/mysql-uptime-check-loop.sh %}) in the SSH terminal. This script connects to the database server to run a simple status check (uptime), and prints out the results. When a RDS failover is triggered, the script is **expected** to show error messages for a period of 30-60 seconds before resuming normal behavior. This demonstrates that the RDS failover happened successfully. To download and run the script, run the following commands in the SSH terminal that is connected to the Wordpress EC2 instance:
```
cd ~
wget {{ site.baseurl }}{% link scripts/mysql-uptime-check-loop.sh %}
chmod 755 mysql-uptime-check-loop.sh
./mysql-uptime-check-loop.sh
```
4. If you have AWS CLI installed, 

### Conclusion

Congratulations! We have completed this lab session. We have learnt:

* How to launch a RDS instance
* How to migrate an application to RDS
* How to scale your RDS database, and make it highly available
* How to simulate database failure to test failover

