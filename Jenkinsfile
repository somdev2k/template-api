pipeline {

    agent any
	
	options {
		timestamps()
	}

    environment {
        GIT_URL = 'https://github.com/somdev2k/template-api.git'
		BUILD_VER = '1.0.0'
        REPO_NAME = env.GIT_URL.replace('.git', '').split('/').last()
        DEPLOY_CREDS = credentials('cloudhub-deploy-creds')
        PLATFORM_CREDS = credentials('anypoint-org-creds')
        ENCRYPT_KEY = credentials('app-encrypt-key')
		MVN_SET = credentials('mule-maven-settings')
		GB_ENV = "UNKNOWN"
    }

    stages {

        /* 
		 *release chain for dev 
		 */

        stage('Checkout - develop') {
            when {
                expression {env.GIT_BRANCH == 'origin/develop'}
            }
            steps {
				echo 'Checkout develop...'
				
				checkout([$class: 'GitSCM', 
						branches: [[name: "*/develop"]], 
						doGenerateSubmoduleConfigurations: false, 
						extensions: [], 
						submoduleCfg: [], 
						userRemoteConfigs: [[
							credentialsId: 'github-creds', 
							url: "$GIT_URL"]]
						])
				
				script {
					GB_ENV = 'dev'					
					env.GIT_COMMIT = sh(returnStdout: true, script: 'git rev-parse HEAD')
					env.GIT_COMMIT_MSG = sh (script: 'git log -1 --pretty=%B ${GIT_COMMIT}', returnStdout: true).trim()
					env.GIT_AUTHOR_NAME = sh (script: 'git log -1 --pretty=%an ${GIT_COMMIT}', returnStdout: true).trim()
					env.GIT_AUTHOR_EMAIL  = sh (script: 'git log -1 --pretty=%ae ${GIT_COMMIT}', returnStdout: true).trim()
					env.BUILD_VER = sh (script: 'mvn -s $MVN_SET help:evaluate -Pexchange -Dexpression=project.version -q -DforceStdout', returnStdout: true)
				}
								
				echo "================================================="
				echo " Initiating Build"
				echo "================================================="
				echo "> ENV : $GB_ENV "
				echo "> BUILD_VER : $BUILD_VER "
				echo "================================================="
				
				sh 'env | grep GIT_'
				sh 'ls -lart ./*'
            }
        }

        stage('Build & Run MUnit - develop') {
            when {
                expression {env.GIT_BRANCH == 'origin/develop'}
            }
            steps {
                echo 'Building ...'
                
				sh 'mvn clean verify -U -s $MVN_SET -Pexchange -Dencrypt.key="$ENCRYPT_KEY"' // help:effective-settings
            }
        }
		
        stage('Deploying in DEV/SIT') {
            when {
                expression {env.GIT_BRANCH == 'origin/develop'}
            }
			environment {
                ENV = 'dev'
            }
            steps {
                echo 'Deploying in DEV/SIT...'
                
				sh 'mvn clean deploy -DmuleDeploy -DskipMunitTests -s $MVN_SET -Pexchange -Dap.ca.client_id="$DEPLOY_CREDS_USR" -Dap.ca.client_secret="$DEPLOY_CREDS_PSW" -Dap.client_id="$PLATFORM_CREDS_USR" -Dap.client_secret="$PLATFORM_CREDS_PSW" -Dencrypt.key="$ENCRYPT_KEY" -Ddeployment.env="$ENV"'
            }
        }
		

         /* 
		 *release chain for test 
		 */

        stage('Checkout - main') {
            when {
                expression {env.GIT_BRANCH == 'origin/main'}
            }
            steps {
				echo 'Checkout main...'
				
				checkout([$class: 'GitSCM', 
						branches: [[name: "*/main"]], 
						doGenerateSubmoduleConfigurations: false, 
						extensions: [], 
						submoduleCfg: [], 
						userRemoteConfigs: [[
							credentialsId: 'github-creds', 
							url: "$GIT_URL"]]
						])
				
				script {
					GB_ENV = 'test'	
					env.GIT_COMMIT = sh(returnStdout: true, script: 'git rev-parse HEAD')
					env.GIT_COMMIT_MSG = sh (script: 'git log -1 --pretty=%B ${GIT_COMMIT}', returnStdout: true).trim()
					env.GIT_AUTHOR_NAME = sh (script: 'git log -1 --pretty=%an ${GIT_COMMIT}', returnStdout: true).trim()
					env.GIT_AUTHOR_EMAIL  = sh (script: 'git log -1 --pretty=%ae ${GIT_COMMIT}', returnStdout: true).trim()
					env.BUILD_VER = sh (script: 'mvn -s $MVN_SET help:evaluate -Pexchange -Dexpression=project.version -q -DforceStdout', returnStdout: true)
				}			
				
				echo "================================================="
				echo " Initiating Build"
				echo "================================================="
				echo "> ENV : $GB_ENV "
				echo "> BUILD_VER : $BUILD_VER "
				echo "================================================="
				
				sh 'env | grep GIT_'
				sh 'ls -lart ./*'
				
            }
        }

        stage('Build & Run Munit - main') {
            when {
                expression {env.GIT_BRANCH == 'origin/main'}
            }
            steps {
                echo 'Building ...'			
                
				sh 'mvn clean verify -U -s $MVN_SET -Pexchange -Dencrypt.key="$ENCRYPT_KEY"'
            }
        }

        stage('Deploying in TEST/UAT') {
            when {
                expression {env.GIT_BRANCH == 'origin/main'}
            }
			environment {
                ENV = 'test'
            }
            steps {
                echo 'Deploying in TEST/UAT...'
                
				sh 'mvn clean deploy -DmuleDeploy -DskipMunitTests -s $MVN_SET -Pexchange -Dap.ca.client_id="$DEPLOY_CREDS_USR" -Dap.ca.client_secret="$DEPLOY_CREDS_PSW" -Dap.client_id="$PLATFORM_CREDS_USR" -Dap.client_secret="$PLATFORM_CREDS_PSW" -Dencrypt.key="$ENCRYPT_KEY" -Ddeployment.env="$ENV"'
            }
        }

        stage('Regression Testing') {
            when {
                expression {env.GIT_BRANCH == 'origin/main'}
            }
            steps {
                echo 'Running regression test...'
                
				sh 'newman run $PWD/postman/$REPO_NAME.postman_collection.json --disable-unicode'
            }
        }

        stage('Approve Deployment on PROD') {
            when {
                expression {env.GIT_BRANCH == 'origin/main'}
            }
            steps {
                timeout(time: 14, unit: 'DAYS') {
                    script {
                        env.DEPLOY_PROD = input message: 'Approve deployment on PROD', parameters: [
                            [$class: 'BooleanParameterDefinition', defaultValue: false, description: '', name: 'Approve deployment on PROD']
                        ]
                    }
                }
            }
        }
		
		/* 
		 *release chain for production 
		 */
		 
		stage('Tagging') {
            when {
                environment name: 'DEPLOY_PROD', value: "true"
            } 
            steps {
                echo 'Tagging main branch...'
				
				script {
					GB_ENV = 'prod'		
				}	
				
            }
        }

        stage('Deploying in PROD') {
            when {
                environment name: 'DEPLOY_PROD', value: "true"
            }
			environment {
                ENV = 'prod'
            }
            steps {
                echo 'Deploying in PROD...'
                
				sh 'mvn mule:deploy -Dmule.artifact=./target/template-api-"$BUILD_VER"-mule-application.jar -s $MVN_SET -Pexchange -Dap.ca.client_id="$DEPLOY_CREDS_USR" -Dap.ca.client_secret="$DEPLOY_CREDS_PSW" -Dap.client_id="$PLATFORM_CREDS_USR" -Dap.client_secret="$PLATFORM_CREDS_PSW" -Dencrypt.key="$ENCRYPT_KEY" -Ddeployment.env="$ENV" -Ddeployment.suffix='
            }
        }

    }
	
	post {
        always {
            archiveArtifacts artifacts: 'target/*.jar, fingerprint: true, onlyIfSuccessful: true
        }
		success {	
			echo "Release to '${GB_ENV}' complete"
        }
    }

    tools {
        maven 'Maven3'
        jdk 'JDK8'
    }
}

/*
*Plugins required:
*-Simple Theme Plugin
*-GitHub Integration Plugin
*-Build Pipeline Plugin
*-Config File Provider
*
*/