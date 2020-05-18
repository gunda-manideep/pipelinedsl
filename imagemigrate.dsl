node
{
properties([parameters([text(defaultValue: '''repo:tag
repo:tag''', description: '', name: 'string'), string(defaultValue: 'registry:port', description: 'Enter Source registry', name: 'SOURCE', trim: false), choice(choices: ['registry:port','registry','registry:port'], description: 'Enter Destination registry', name: 'DESTINATION')])])

stage('Image migration'){
def list = string.split("\\r?\\n").each { param ->
    //println "${param}"
    }
    for (int i = 0; i < list.size(); i++)
                    {
                    def filename = list[i]
                    echo "${filename}"
                    docker.withRegistry("https://${params.SOURCE}")
                    {
                    image = docker.image("${filename}")
                    image.pull()
                    }
                   //docker tag
                    sh "docker tag ${params.SOURCE}/${filename} ${params.DESTINATION}/${filename}"     
       
      //push image to destiantion registry
                    sh "az acr login --name registry"
                    image = docker.image("${params.DESTINATION}/${filename}")
                    docker.withRegistry("https://${params.DESTINATION}")
                    {
                         image.push()
                         }
        //delete pulled and tagged images
                    sh "docker rmi ${params.SOURCE}/${filename} && docker rmi ${params.DESTINATION}/${filename} "
   
}
}
stage('Email Notifications')
{
  sh label: '', script: '''aws sns publish \\
    --topic-arn "arn:xxx:xx:xxxxxxx:xxxxxx:xxxxxx" \\
    --message "The following images : ${string} are pushed  from ${SOURCE} to ${DESTINATION}"'''
  
  
}
}
