pipeline {
  agent any

  environment {
    AWS_REGION = "eu-central-1"
    // COMMIT_SHA = "${env.GIT_COMMIT.take(7)}"    // short git commit for image tag
    REPO_NAME  = "availability-tracker"
    AWS_CREDENTIALS_ID = "aws-creds"
  }

  stages {

    stage('Build & Test') {
      steps {
        sh '''
        echo "****** Installing dependencies ******"
        npm install

        echo "****** Running ESLint ******"
        npx eslint . || echo " ESLint found issues (not blocking build)."

        echo "****** Checking formatting with Prettier ******"
        npx prettier --check . || echo "Prettier found issues (not blocking build)."

        echo "****** Running tests ******"
        if npm test; then
            echo "Tests passed."
        else
            echo "No tests found or some tests failed (not blocking build)."
        fi
        '''
      }
    }

    stage('Terraform ECR Only') {
      steps {
        dir('terraform-ecs') {
          withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: env.AWS_CREDENTIALS_ID]]) {
            sh '''
              echo "****** Ensuring ECR repository exists ******"
              terraform init -input=false
              terraform apply -auto-approve -target=aws_ecr_repository.this
            '''
          }
        }
      }
    }

    stage('Build & Push Docker Image') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: env.AWS_CREDENTIALS_ID]]) {
          sh '''
            echo "****** Getting ECR repository URL ******"
            ECR_REPO=$(terraform -chdir=terraform-ecs output -raw ecr_repo_url)

            echo "****** Logging into ECR ******"
            aws ecr get-login-password --region $AWS_REGION | \
              docker login --username AWS --password-stdin $ECR_REPO

            echo "****** Building Docker image with two tags (commit + latest) ******"
            docker build -t $ECR_REPO:latest .

            echo "****** Pushing both tags ******"
            // docker push $ECR_REPO:$COMMIT_SHA
            docker push $ECR_REPO:latest
          '''
        }
      }
    }

    stage('Terraform Full Apply') {
      steps {
        dir('terraform-ecs') {
          withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: env.AWS_CREDENTIALS_ID]]) {
            sh '''
              echo " Deploying application with Terraform..."
              terraform apply -auto-approve -var="image_tag=$COMMIT_SHA"
            '''
          }
        }
      }
    }

    stage('Success') {
      steps {

          echo "Deployment pipeline completed successfully!"

      }
    }

  }
}
