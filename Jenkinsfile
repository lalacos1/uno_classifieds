pipeline {
  agent {
    node {
      label 'application'
    }
    
  }
  stages {
    stage('Prep') {
      steps {
        sh '''gem install bundler
bundle install

'''
        catchError() {
          sh 'docker kill $(docker ps -q)'
          sh 'ls -la'
        }
        
      }
    }
    stage('Verify') {
      parallel {
        stage('Lint') {
          steps {
            sh '''bundle exec rubocop --format html -o rubocop.html || true
bundle exec rubocop --format json -o rubocop.json || true'''
            script {
              publishHTML(target: [
                allowMissing: false,
                alwaysLinkToLastBuild: false,
                keepAll: true,
                reportDir: '',
                reportFiles: 'rubocop.html',
                reportTitles: "Lint Report",
                reportName: "Lint Report"
              ])
            }
            
            archiveArtifacts 'rubocop.json'
          }
        }
        stage('Syntax') {
          steps {
            sh 'ruby -c **/*.rb'
          }
        }
        stage('Unit') {
          steps {
            sh '''
  docker run -dt -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch:6.0.0 > .es_container_id
  sleep 30;
  bundle exec rspec


'''
            script {
              publishHTML(target: [
                allowMissing: false,
                alwaysLinkToLastBuild: false,
                keepAll: true,
                reportDir: '',
                reportFiles: 'rspec.html',
                reportTitles: "Unit Test Report",
                reportName: "Unit Test Report"
              ])
              
              publishHTML(target: [
                allowMissing: false,
                alwaysLinkToLastBuild: false,
                keepAll: true,
                reportDir: 'coverage',
                reportFiles: 'index.html',
                reportTitles: "Coverage Report",
                reportName: "Coverage Report"
              ])
              
              publishHTML(target: [
                allowMissing: false,
                alwaysLinkToLastBuild: false,
                keepAll: true,
                reportDir: 'rspec_html_reports',
                reportFiles: 'overview.html',
                reportTitles: "New Unit Test Report",
                reportName: "New Unit Test Report"
              ])
              
              s3Upload acl: 'Private', bucket: 'mutation-analysis', file: 'coverage.json', path: "uno_classifieds/master/${env.BUILD_NUMBER}/", workingDir: "coverage"
            }
            
            archiveArtifacts 'coverage/coverage.json'
          }
        }
        stage('Quality') {
          steps {
            sh '''bundle exec rubycritic --no-browser --format json
bundle exec rubycritic --no-browser'''
            script {
              publishHTML(target: [
                allowMissing: false,
                alwaysLinkToLastBuild: false,
                keepAll: true,
                reportDir: 'tmp/rubycritic',
                reportFiles: 'overview.html',
                reportTitles: "Quality Report",
                reportName: "Quality Report"
              ])
            }
            
            archiveArtifacts 'tmp/rubycritic/report.json'
          }
        }
      }
    }
    stage('Mutate') {
      steps {
        catchError() {
          sh '''
RAILS_ENV=test bundle exec mutant -r ./config/environment --use rspec User > mutate.out


'''
        }
        
        script {
          publishHTML(target: [
            allowMissing: false,
            alwaysLinkToLastBuild: false,
            keepAll: true,
            reportDir: 'coverage',
            reportFiles: 'index.html',
            reportTitles: "Mutation Report",
            reportName: "Mutation Report"
          ])
        }
        
      }
    }
    stage('Kill') {
      steps {
        sh 'docker kill $(docker ps -q)'
      }
    }
    stage('Upload') {
      steps {
        script {
          s3Upload acl: 'Private', bucket: 'mutation-analysis', file: 'rubocop.json', path: "uno_classifieds/master/${env.BUILD_NUMBER}/"
          
          s3Upload acl: 'Private', bucket: 'mutation-analysis', file: 'coverage.json', path: "uno_classifieds/master/${env.BUILD_NUMBER}/mutate_coverage.json", workingDir: "coverage"
          
          s3Upload acl: 'Private', bucket: 'mutation-analysis', file: 'report.json', path: "uno_classifieds/master/${env.BUILD_NUMBER}/", workingDir: "tmp/rubycritic"
          
          s3Upload acl: 'Private', bucket: 'mutation-analysis', file: 'mutate.out', path: "uno_classifieds/master/${env.BUILD_NUMBER}/"
        }
        
      }
    }
  }
}