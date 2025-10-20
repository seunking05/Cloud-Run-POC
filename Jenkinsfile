pipeline {
  agent any

  environment {
    PROJECT_ID = 'swift-castle-475200-j1'
    REGION = 'us-central1'
    SERVICE = 'node-cloudrun-demo'
    IMAGE_NAME = "${REGION}-docker.pkg.dev/${PROJECT_ID}/node-repo/${SERVICE}:${env.BUILD_NUMBER}"
    GOOGLE_APPLICATION_CREDENTIALS = credentials('gcp-service-account-key')  // Jenkins credential ID
  }

  stages {

    stage('Checkout Code') {
      steps {
        echo "Cloning repository..."
        git branch: 'main', url: 'https://github.com/seunking05/Cloud-Run-POC.git'
      }
    }

    stage('Setup gcloud CLI') {
      steps {
        echo "Installing and authenticating gcloud..."
        sh '''
          if ! command -v gcloud &> /dev/null
          then
            echo "Installing Google Cloud SDK..."
            curl https://sdk.cloud.google.com | bash > /dev/null
            exec -l $SHELL
          fi
          echo $GOOGLE_APPLICATION_CREDENTIALS > key.json
          gcloud auth activate-service-account --key-file=key.json
          gcloud config set project $PROJECT_ID
        '''
      }
    }

    stage('Configure Docker Authentication') {
      steps {
        echo "Configuring Docker to use gcloud credentials..."
        sh 'gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet'
      }
    }

    stage('Build Docker Image') {
      steps {
        echo "Building Docker image..."
        sh 'docker build -t ${IMAGE_NAME} .'
      }
    }

    stage('Push Docker Image') {
      steps {
        echo "Pushing image to Artifact Registry..."
        sh 'docker push ${IMAGE_NAME}'
      }
    }

    stage('Deploy to Cloud Run') {
      steps {
        echo "Deploying to Cloud Run service: ${SERVICE}"
        sh '''
          gcloud run deploy ${SERVICE} \
            --image=${IMAGE_NAME} \
            --region=${REGION} \
            --platform=managed \
            --allow-unauthenticated
        '''
      }
    }
  }

  post {
    success {
      echo "✅ Deployment successful! Cloud Run service ${SERVICE} is live."
    }
    failure {
      echo "❌ Deployment failed. Check the Jenkins logs for details."
    }
  }
}
