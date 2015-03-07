 #!/bin/bash

#default values if no CLI arguments is used
dir_to_bk="/home/v4lproik"
dir_to_store_bk="/media/v4lproik/Versatile/BACKUP/"
now=$(date +"%F")
name_of_archive="home_backup_$now"
password="your_password"

usage(){
	echo "Usage $0:\n --encrypt <dir_to_backup> <dir_to_store_backup> <name_of_archive>\n --decrypt"
}

decrypt(){
	echo "Decryption in progress..."
        read -r -p "Provide the path of the archive: " response
        openssl aes-256-cbc -d -salt -in $response | tar -x -f -
}

encrypt(){
        echo "Encryption in progress"

        command -v pv >/dev/null 2>&1 || { echo >&2 "I require pv but it's not installed.  Aborting."; exit 1; }

        read -r -p "Do you want to run the backup of the folder $dir_to_bk? [y/N] " response
        case $response in
	        [yY][eE][sS]|[yY]) 
                 echo "Calculating folder's size... please wait..."
                 SIZE=`du -sk $dir_to_bk | cut -f 1`
		 echo "Backup will be stored in $dir_to_store_bk/$name_of_archive.tar.aes"
                 tar -c $dir_to_bk | pv -p -s ${SIZE}k | openssl aes-256-cbc -k $password -salt -out $dir_to_store_bk/$name_of_archive.tar.aes
		 echo "Encryption is done"
	;;
	
        *)
                 echo "Exiting..."
        ;;
        esac

}

#check permissions
if [ `id -u` != 0 ] ; then
        echo "You need to run this script with root permissions... Exiting..."
	exit 1
fi

#check if arguments
if [ $# -eq 0 ]
  then
	usage
	exit 1
fi


if [ $1 = "--decrypt" ]; then
	decrypt
else
	if [ $1 = "--encrypt" ]; then
		#check if arguments then set the global variables
        	if [ $# -eq 4 ]; then
		        dir_to_bk=$2
		        dir_to_store_bk=$3
        		name_of_archive="$4_$now"
        	else
			#if the user tries to set the variables but in a bad way
                	if [ $# -gt 1 ]; then
                        	usage
                        	echo "Bad arguments... Exiting..."
                        	exit 1;
                	fi
        	fi
		encrypt
	else
		usage
		echo "Bad argument... Exiting..."
		exit
	fi  	
fi

exit 0

#decrypt
#openssl aes-256-cbc -d -salt -in directory.tar.aes | tar -x -f -
