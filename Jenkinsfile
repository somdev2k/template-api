pipeline {

    agent any

    environment {
        DEPLOY_CREDS = credentials('cloudhub-deploy-creds')
        PLATFORM_CREDS = credentials('anypoint-org-creds')
        ENCRYPT_KEY = credentials('app-encrypt-key')
		MVN_SET = credentials('mule-maven-settings')
		GIT_URL = 'https://github.com/somdev2k/template-api.git'
    }

    stages {
	
		// release pipeline for develop branch
		
		stage('Checkout - develop'){
			when {
                expression {env.GIT_BRANCH == '*/develop'}
            }
            steps {
                echo 'Checkout ...'
				echo env.GIT_BRANCH
                checkout([$class: 'GitSCM', branches: [[name: "*/develop"]], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'github-creds', url: "$GIT_URL"]]])
                
				sh 'ls -lart ./*'
            }
        }
        
        stage('Build & UnitTest - develop'){
			when {
               expression {env.GIT_BRANCH == '*/develop'}
            }
            steps {
                echo 'Building ...'
                sh 'mvn clean verify -U -s $MVN_SET -Dencrypt.key="$ENCRYPT_KEY"'
            }
        }
		
		 stage('Deploying in DEV/SIT'){
            when {
                expression {env.GIT_BRANCH == '*/develop'}
            }
            environment {
                ENV = 'dev'
            }
            steps {
                echo 'Deploying in DEV/SIT...'

				sh 'mvn clean deploy -DmuleDeploy -DskipMunitTests -Dap.ca.client_id="$DEPLOY_CREDS_USR" -Dap.ca.client_secret="$DEPLOY_CREDS_PSW" -Dap.client_id="$PLATFORM_CREDS_USR" -Dap.client_secret="$PLATFORM_CREDS_PSW" -Dencrypt.key="$ENCRYPT_KEY" -Ddeployment.env="$ENV"'
            }
        }
		
		
		// release pipeline for main branch
		
		stage('Checkout - main'){
			when {
                expression {env.GIT_BRANCH == '*/main'}
            }
            steps {
                echo 'Checkout ...'
				echo env.GIT_BRANCH
                checkout([$class: 'GitSCM', branches: [[name: "*/main"]], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'github-creds', url: "$GIT_URL"]]])
                
				sh 'ls -lart ./*'
            }
        }
        
        stage('Build & UnitTest - main'){
			when {
                expression {env.GIT_BRANCH == '*/main'}
            }
            steps {
                echo 'Building ...'
                sh 'mvn clean verify -U -s $MVN_SET -Dencrypt.key="$ENCRYPT_KEY"'
            }
        }
		
		 stage('Deploying in TEST/UAT'){
            when {
                expression {env.GIT_BRANCH == '*/main'}
            }
            environment {
                ENV = 'test'
            }
            steps {
                echo 'Deploying in TEST/UAT...'

				sh 'mvn clean deploy -DmuleDeploy -DskipMunitTests -Dap.ca.client_id="$DEPLOY_CREDS_USR" -Dap.ca.client_secret="$DEPLOY_CREDS_PSW" -Dap.client_id="$PLATFORM_CREDS_USR" -Dap.client_secret="$PLATFORM_CREDS_PSW" -Dencrypt.key="$ENCRYPT_KEY" -Ddeployment.env="$ENV"'
            }
        }
		
		stage('Regression Testing'){
            
            environment {
                ENV = 'test'
            }
            steps {
                echo 'Running regression test...'

				sh 'newman run $PWD/postman/template-api.postman_collection.json'
            }
        }
		
		stage('Approve deployment on PROD') {
			when {
                expression {env.GIT_BRANCH == '*/main'}
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
		
        stage('Deploying in PROD'){
            when {
                environment name: 'DEPLOY_PROD', value: "true"
            }
            environment {
                ENV = 'prod'
            }
            steps {
                echo 'Deploying in PROD...'

                sh 'mvn mule:deploy -Dmule.artifact=./target/template-api-1.0.0-mule-application.jar -Dap.ca.client_id="$DEPLOY_CREDS_USR" -Dap.ca.client_secret="$DEPLOY_CREDS_PSW" -Dap.client_id="$PLATFORM_CREDS_USR" -Dap.client_secret="$PLATFORM_CREDS_PSW" -Dencrypt.key="$ENCRYPT_KEY" -Ddeployment.env="$ENV" -Ddeployment.suffix='
            }
        }
        
    }

    tools {
        maven 'Maven3'
    }
}