#########################################################################################################################
README
This dsl script is capable for migrating docker images from one registry to another registry. I have used multiline string parameter and choice parameters.
when you run this pipeline job we have to select build with parameters. 

1.we have to provide reponame:tagname of the docker image in the string field. 
2.We have to select sourceresgistry with port in the source field.
3.We have to choose a docker registry as destination this can be AWS or Azure.

###########################################################################################################################



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
