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
    }

    stages {

        /* 
		 *release pipeline for develop branch 
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
					env.GIT_COMMIT = sh(returnStdout: true, script: 'git rev-parse HEAD')
					env.GIT_COMMIT_MSG = sh (script: 'git log -1 --pretty=%B ${GIT_COMMIT}', returnStdout: true).trim()
					env.GIT_AUTHOR_NAME = sh (script: 'git log -1 --pretty=%an ${GIT_COMMIT}', returnStdout: true).trim()
					env.GIT_AUTHOR_EMAIL  = sh (script: 'git log -1 --pretty=%ae ${GIT_COMMIT}', returnStdout: true).trim()
					env.BUILD_VER = sh (script: 'mvn help:evaluate -Dexpression=project.version -q -DforceStdout', returnStdout: true)
				}

				echo "================================================="
				echo "GIT_COMMIT : $GIT_COMMIT "
				echo "GIT_COMMIT_MSG : $GIT_COMMIT_MSG "
				echo "GIT_AUTHOR_NAME : $GIT_AUTHOR_NAME "
				echo "GIT_AUTHOR_EMAIL : $GIT_AUTHOR_EMAIL "
				echo "BUILD_VER : $BUILD_VER "
				echo "================================================="
				
				sh 'ls -lart ./*'
            }
        }

        stage('Build & Run MUnit - develop') {
            when {
                expression {env.GIT_BRANCH == 'origin/develop'}
            }
            steps {
                echo 'Building ...'
                sh 'mvn clean verify -U -s $MVN_SET -Dencrypt.key="$ENCRYPT_KEY"'
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
                sh 'mvn clean deploy -DmuleDeploy -DskipMunitTests -Dap.ca.client_id="$DEPLOY_CREDS_USR" -Dap.ca.client_secret="$DEPLOY_CREDS_PSW" -Dap.client_id="$PLATFORM_CREDS_USR" -Dap.client_secret="$PLATFORM_CREDS_PSW" -Dencrypt.key="$ENCRYPT_KEY" -Ddeployment.env="$ENV"'
            }
        }


         /* 
		 *release pipeline for main branch 
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
					env.GIT_COMMIT = sh(returnStdout: true, script: 'git rev-parse HEAD')
					env.GIT_COMMIT_MSG = sh (script: 'git log -1 --pretty=%B ${GIT_COMMIT}', returnStdout: true).trim()
					env.GIT_AUTHOR_NAME = sh (script: 'git log -1 --pretty=%an ${GIT_COMMIT}', returnStdout: true).trim()
					env.GIT_AUTHOR_EMAIL  = sh (script: 'git log -1 --pretty=%ae ${GIT_COMMIT}', returnStdout: true).trim()
					env.BUILD_VER = sh (script: 'mvn help:evaluate -Dexpression=project.version -q -DforceStdout', returnStdout: true)
				}			
				
				echo "================================================="
				echo "GIT_COMMIT : $GIT_COMMIT "
				echo "GIT_COMMIT_MSG : $GIT_COMMIT_MSG "
				echo "GIT_AUTHOR_NAME : $GIT_AUTHOR_NAME "
				echo "GIT_AUTHOR_EMAIL : $GIT_AUTHOR_EMAIL "
				echo "BUILD_VER : $BUILD_VER "
				echo "================================================="
				
				sh 'ls -lart ./*'
            }
        }

        stage('Build & Run Munit - main') {
            when {
                expression {env.GIT_BRANCH == 'origin/main'}
            }
            steps {
                echo 'Building ...'			
                sh 'mvn clean verify -U -s $MVN_SET -Dencrypt.key="$ENCRYPT_KEY"'
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
                sh 'mvn clean deploy -DmuleDeploy -DskipMunitTests -Dap.ca.client_id="$DEPLOY_CREDS_USR" -Dap.ca.client_secret="$DEPLOY_CREDS_PSW" -Dap.client_id="$PLATFORM_CREDS_USR" -Dap.client_secret="$PLATFORM_CREDS_PSW" -Dencrypt.key="$ENCRYPT_KEY" -Ddeployment.env="$ENV"'
            }
        }

        stage('Regression Testing') {
            when {
                expression {env.GIT_BRANCH == 'origin/main'}
            }
            environment {
                ENV = 'test'
            }
            steps {
                echo 'Running regression test...'
                sh 'newman run $PWD/postman/$REPO_NAME.postman_collection.json --disable-unicode -r htmlextra --reporter-htmlextra-export $PWD/postman/ --reporter-htmlextra-darkTheme'
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

        stage('Deploying in PROD') {
            when {
                environment name: 'DEPLOY_PROD', value: "true"
            }
            environment {
                ENV = 'prod'
            }
            steps {
                echo 'Deploying in PROD...'
                sh 'mvn mule:deploy -Dmule.artifact=./target/template-api-"$BUILD_VER"-mule-application.jar -Dap.ca.client_id="$DEPLOY_CREDS_USR" -Dap.ca.client_secret="$DEPLOY_CREDS_PSW" -Dap.client_id="$PLATFORM_CREDS_USR" -Dap.client_secret="$PLATFORM_CREDS_PSW" -Dencrypt.key="$ENCRYPT_KEY" -Ddeployment.env="$ENV" -Ddeployment.suffix='
            }
        }

    }
	
	post {
        always {
            archiveArtifacts artifacts: 'target/*.jar, postman/*.html', fingerprint: true, onlyIfSuccessful: true
        }
		success {
          sh 'echo Release complete!'
        }
    }

    tools {
        maven 'Maven3'
        jdk 'JDK8'
    }
}