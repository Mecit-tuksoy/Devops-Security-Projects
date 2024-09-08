# "Creating and Securing Netflix Clone on GCP Using DevOps Tools (SonarQube, OWASP, Trivy, Jenkins, Docker, Prometheus, Grafana)"

## This project aims to create a clone of the popular streaming platform Netflix and securely deploy it using modern DevOps practices. 

The project includes:

- A Netflix-like user interface developed using React and TypeScript.

- Using real movie and TV show data with TMDB API integration.

- Setting up a continuous integration and continuous delivery (CI/CD) pipeline with Jenkins.

- Conducting code quality and security analysis with SonarQube.

- Conducting security scans with OWASP and Trivy tools.

- Containerizing the application using Docker.

- Deploying the application on Google Cloud Platform (GCP).

- Monitoring application performance and infrastructure with Prometheus and Grafana.

This project aims to create a secure, scalable, and high-performance streaming platform clone by combining modern web development techniques, DevOps practices, and cloud technologies. At the same time, it provides a continuous improvement and security-focused development process using industry-standard tools.


# Proje aşamaları:

## 1- Gcloud'da VM instances oluştur (Ubuntu 22.04.4 LTS  ve  20 GB)
## 2- İnstance için firewall ayarlarını yap. İhtiyacımız olacak portlar: 8080, 8081, 9000, 9090, 9100
## 3- Bu server'a:
    1- Jenkins kurulumunu yap ve brawserdan erişimi sağla
    2- Docker kurulumu yap
    3- SonarQube Konteynerini Oluştur sh``docker run -d --name sonar -p 9000:9000 sonarqube:lts-community`` 
    4- Trivy Kurulumu yap

## 4- İzleme Sunucusu Kurulumu yap, yeni bir VM örneği oluşturacağız ve bunu izleme sunucumuz olarak kullanacağız. (Ubuntu 22.04.4 LTS ve 20 GB)

## 5- Prometheus'u İzleme Sunucusuna Kurun bunun için:
    1- 
    - “prometheus” adında bir sistem kullanıcısı oluşturu`yoruz
    sh``sudo useradd \ 
    --system \ 
    --no-create-home \ 
    --shell /bin/false prometheus``
    
    2- 
    - Prometheus dosyasını indir
    sh``wget https://github.com/prometheus/prometheus/releases/download/v2.51.2/prometheus-2.51.2.linux-amd64.tar.gz``
  
    - Tar dosyasını açıyoruz:
    sh``tar -xvf prometheus-2.51.2.linux-amd64.tar.gz``
   
    - Prometheus verileri ve yapılandırma dosyaları için dizinler oluştur
    sh ``sudo mkdir -p /data /etc/prometheus ``

    - Prometheus ikili dosyalarını /usr/local/bin/ dizinine taşı 
    sh ``cd prometheus-2.51.2.linux-amd64/ 
        sudo mv prometheus promtool /usr/local/bin/ ``

    - Konsol şablonlarını ve kitaplıklarını /etc/prometheus/ dizinine taşı
    sh ``sudo mv consoles/ console_libraries/ /etc/prometheus/ ``

    - Prometheus yapılandırma dosyasını /etc/prometheus/ dizinine taşı
    sh ``sudo mv prometheus.yml /etc/prometheus/prometheus.yml ``

    - Prometheus yapılandırma ve veri dizinlerinin sahipliğini 'prometheus' kullanıcısına değiştir
    sh ``sudo chown -R prometheus:prometheus /etc/prometheus/ /data/ ``

    - Ana dizine geri dön 
    sh ``cd`` 

    - İndirilen Prometheus arşiv dosyasını kaldır 
    sh ``rm -rf prometheus-2.51.2.linux-amd64.tar.gz ``

    - Prometheus sürümünü kontrol et
    sh `` prometheus --version ``

    - Prometheus yardımını görüntüle
    sh `` prometheus --help ``

    3-
    Prometheus için systemd yapılandırması, Prometheus'un Linux sistemlerinde bir hizmet olarak çalışmasını sağlayarak sistem yeniden başlatıldığında veya hizmetin yönetilmesi gerektiğinde otomatik olarak başlamasını sağlar.

    sh````
     sudo nano /etc/systemd/system/prometheus.service
    ````
    sh````
    [Unit]
    Description=Prometheus
    Wants=network-online.target
    After=network-online.target

    StartLimitIntervalSec=500
    StartLimitBurst=5

    [Service]
    User=prometheus
    Group=prometheus
    Type=simple
    Restart=on-failure
    RestartSec=5s
    ExecStart=/usr/local/bin/prometheus \
        --config.file=/etc/prometheus/prometheus.yml \
        --storage.tsdb.path=/data \
        --web.console.templates=/etc/prometheus/consoles \
        --web.console.libraries=/etc/prometheus/console_libraries \
        --web.listen-address=0.0.0.0:9090 \
        --web.enable-lifecycle

    [Install]
    WantedBy=multi-user.target
    ````

    sudo systemctl enable prometheus 
    sudo systemctl start prometheus 
    sudo systemctl status prometheus


## 6- Node Exporter'u İzleme Sunucusuna Kurun bunun için:
     1- 
    sh``
     sudo useradd \
     --system \
     --no-create-home \
     -shell /bin/false node_exporter
      ``
     2- 
    - Node Exporter dosyasını indir
    sh``wget https://github.com/prometheus/node_exporter/releases/download/v1.8.0/node_exporter-1.8.0.linux-amd64.tar.gz``
  
    - Tar dosyasını açıyoruz:
    sh``tar -xvf node_exporter-1.8.0.linux-amd64.tar.gz``
   
    - Node Exporter dosyasını /usr/local/bin/ dizinine taşı 
    sh ``sudo mv node_exporter-1.8.0.linux-amd64/node_exporter /usr/local/bin/``

    - İndirilen Node Exporter arşiv dosyasını kaldır 
    sh ``rm -rf node_exporter* ``

    - Node Exporter sürümünü kontrol et
    sh `` node_exporter --version``

    - Node Exporter yardımını görüntüle
    sh `` node_exporter --help ``

    3-
    Node Exporter için systemd yapılandırması, Node Exporter'un Linux sistemlerinde bir hizmet olarak çalışmasını sağlayarak sistem yeniden başlatıldığında veya hizmetin yönetilmesi gerektiğinde otomatik olarak başlamasını sağlar.

    sh````
      sudo nano /etc/systemd/system/node_exporter.service
    ````

    sh````

    [Unit]
    Description=Node Exporter
    Wants=network-online.target
    After=network-online.target

    StartLimitIntervalSec=500
    StartLimitBurst=5

    [Service]
    User=node_exporter
    Group=node_exporter
    Type=simple
    Restart=on-failure
    RestartSec=5s
    ExecStart=/usr/local/bin/node_exporter \
        --collector.logind

    [Install]
    WantedBy=multi-user.target
    ````


    sudo systemctl enable node_exporter
    sudo systemctl start node_exporter
    sudo systemctl status node_exporter


## 7- Prometheus için Statik Hedef Oluşturma
    
    1-
    sh``
    sudo nano /etc/prometheus/prometheus.yml
    ``

    2- prometheus.yml dosyasının en altına bunu yapıştır:
    sh``
    - job_name: node_export
      static_configs:
        - targets: ["localhost:9100"]
    ``

    3- Kontrol için:
    sh ``
    promtool check config /etc/prometheus/prometheus.yml
    curl -X POST http://localhost:9090/-/reload
    ``

## 8- Jenkins Server'a Node Exporter Kurulumu ve Statik Hedef Oluşturma

    1- 
    sh``
    sudo useradd --system --no-create-home --shell /bin/false node_exporter
    ``

    2- Dosyayı indir
    wget https://github.com/prometheus/node_exporter/releases/download/v1.8.0/node_exporter-1.8.0.linux-amd64.tar.gz 

    3- Arşiv dosyasını çıkar
    tar -xvf node_exporter-1.8.0.linux-amd64.tar.gz

    4-
    sudo mv node_exporter-1.8.0.linux-amd64/node_exporter /usr/local/bin/

    5-
    rm -rf node_exporter*

    6-
    node_exporter --version

    7-
    sudo nano /etc/systemd/system/node_exporter.service

    # node_exporter.service configurations file
        [Unit]
        Description=Node Exporter
        Wants=network-online.target
        After=network-online.target

        StartLimitIntervalSec=500
        StartLimitBurst=5

        [Service]
        User=node_exporter
        Group=node_exporter
        Type=simple
        Restart=on-failure
        RestartSec=5s
        ExecStart=/usr/local/bin/node_exporter \
            --collector.logind

        [Install]
        WantedBy=multi-user.target
    
    # start and enable node_exporter
        sudo systemctl enable node_exporter
        sudo systemctl start node_exporter
        sudo systemctl status node_exporter

## 9- Monitoring server'da prometheus.yml configürasyon dosyasına jenkins serverı hedef olarak ekliyoruz: 
    
    sudo nano /etc/prometheus/prometheus.yml 

    ```bash
    - job_name: node_export_jenkins
        static_configs:
          - targets: ["jenkins-server-publicIP:9100"]
    ```

    Kontrol için:
    promtool check config /etc/prometheus/prometheus.yml
    curl -X POST http://localhost:9090/-/reload 

## 9- Monitörig serverda Grafana Kurulumu ve Yapılandırması:

    1- Install necessary packages for adding Grafana repository
    sudo apt-get install -y apt-transport-https software-properties-common

    2- Add Grafana GPG key to verify package integrity
    wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

    3- Add Grafana repository to APT sources
    echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

    4- Update package lists to include Grafana packages
    sudo apt-get update

    5- Install Grafana
    sudo apt-get -y install grafana

    6- Enable Grafana service to start on boot
    sudo systemctl enable grafana-server

    7- Start Grafana service
    sudo systemctl start grafana-server

    8- Check status of Grafana service
    sudo systemctl status grafana-server

    9- Kurulu başarılı olduktan sonra monitöring serverin public ipsi ile 3000 portundan Grafana'ya giriş yapıyoruz 

    10- Kullanıcı adı ve şifre "admin" olarak devam edip yeni şifre belirliyoruz.

    11- "Data Sources" olarak Prometheus seçiyoruz. Buraya monitöring serverın public ipsini ekliyoruz.

    12- Dashboarts kısmından güzel bir dashbort import ediyoruz. Ben "1860" kullandım.


## 10- Prometheus Eklentisinin Jenkins'e Kurulumu ve Entegrasyonu:

    1- Jenkins_server_public_ip :8080 ile jenkinse bağlan
    
    2- “Jenkins’i Yönet” → “Eklentileri Yönet” → “Kullanılabilir Eklentiler”e gidin.

    3- Burada arama çubuğuna "prometheus" yaz. ilk çıkan eklentiyi indir.

    4- Jenkin'i yeniden başlat.

    5- http://Jenkins_server_public_ip:8080/prometheus   adresinden JSON formatında metrikler görebiliyorsanız, endpoint çalışıyor demektir. Eğer çalışmıyorsa, Jenkins'teki eklentiyi kontrol edin.


## 11- Monitöring serverda prometheus.yml konfigürasyon dosyasına jenkinsi ekle

    1- sudo nano /etc/prometheus/prometheus.yml

    2- 
    - job_name: jenkins
      metrics_path: "/prometheus"
      static_configs:
        - targets: ["<jenkins-ip>:8080"]
  
    3- Kontrol için:
    promtool check config /etc/prometheus/prometheus.yml
    curl -X POST http://localhost:9090/-/reload


## 12- Jenkins ile E-posta Entegrasyonunu Ayarlama ve Eklentiyi Yükleme

    1- Burada, e-posta gönderebilmek için Gmail hesabımızdan bir uygulama şifresi almamız gerekiyor. Gmail hesabımıza gidelim ve şifreyi üretelim.
       Bu işlemlerin yapılabilmesi için iki adımlı doğrulamanın etkinleştirilmesi gerekmektedir.
       Bu işlemi yaptıktn sonra "uygulama şifreleri"ne gidin. Bir ad belirleyin "jenkins" ve oluştur deyin.
       Gelen şifreyi kaydedin.

    2- Jenkinse girerek Jenkins'i Yönet > Sistem > E-posta Bilgilendirmesi  bölümüne geliyoruz. Aşağıdaki bölümleri dolduralım.
       SMTP sunucusu
        "smtp.gmail.com"
       Use SMTP Authentication?
        Kullanıcı adı
        "mecit.tuksoy@gmail.com"
        şifre
        "kaydettiğimiz şifreyi girelim"
        SSL kullan  kısmına tik koyuyoruz.
        SMTP Portu?
         "465"
        İsterseniz en alttaki kısmı doldurarak test maili atabilirsiniz.
    
    3- Jenkinsfile kullanımı için kimlik bilgileri olarak e-postamızı ve şifrelerimizi ekliyoruz.

       “Jenkins'i Yönet” → “Kimlik Bilgileri”ne gidin ve e-posta kullanıcı adınızı ve oluşturulan parolayı ekleyin. 
       Kind
        "Username with password"
       Username
        "mecit.tuksoy@gmail.com"
       ID
        "mail"
       oluştur.
    
    4- Jenkins'i Yönet > Sistem > Extended E-mail Notification

       SMTP server
        "smtp.gmail.com"
       SMTP Port
        "465"
       Credentials
        "mecit.tuksoy@gmail.com/****** (mail)"
        "Use SSL"
       Default Content Type
        "HTML (text/html)"
       Default Triggers
         "Always" ve "failure- Any"
       Kaydet


## 13- Jenkins İşi ​​Oluşturma

    1- "Yeni Öğe" tıkla isim "Netfilix" gir "Pipeline" işaretle ve "Tamam" tıkla.
       "Pipeline" tıklayarak "script" kısmına aşağıdaki post bloğunu yapıştırın ve kaydedin.

        post {
            always {
                emailext attachLog: true,
                    subject: "'${currentBuild.result}'",
                    body: "Project: ${env.JOB_NAME}<br/>" +
                        "Build Number: ${env.BUILD_NUMBER}<br/>" +
                        "URL: ${env.BUILD_URL}<br/>",
                    to: 'mecit.tuksoy@gmail.com@gmail.com',  #change Your mail
                    attachmentsPattern: 'trivyfs.txt,trivyimage.txt'
                }
            }



## 14- Manage Jenkins'te Sonar Sunucusunu Yapılandırma

   1- Container ile kurduğumuz Sonarqube'e tarayıcıdan "public_ip:9000" ile girelim
   
   2- Administration > security > Users > Update Token yaptıktan sonra buraya bir isim veriyorum "jenkin" gibi gün seçip "Generate" tıkla. 

   3- Oluşan tokenı kaydetmek için jenkinsde: 
   "Manage Jenkins → Credentials → System → Global Credentials → Add Credentials → Secret Text'e" git
   "Secret" kısmına tokenı yapıştır
   "ID" kısmına "Sonar-token" gibi bir isim ver. "Create" tıkla.

   4- Jenkins’e "SonarQube Scanner" eklentisini yüklemek için:
   "Manage Jenkins → Eklentiler → Yüklenebilecek eklentiler → arama çubuğuna "SonarQube Scanner" yaz ve eklentiyi yükle.

   5- "Manage Jenkins → System → SonarQube server → Add SonarQube "
   "Name" = sonar-server
   "Server URL" = SonarQube-public-ip:9000
   "Server authentication token" = Sonar-token
   kaydet

   5- "Manage Jenkins → Tool → SonarQube Scanner kurulumları → 
   "Name" = sonar-scanner
   "Version" = 5.0.1.3006
   kaydet

   6- Tarayıcımızdaki SonarQube' gidip 
   Administration > Cofiguration > Webhooks > Create >
   "Name" = jenkins
   "URL" = http://jenkins-server-ip:8080/sonarqube-webhook/
   create


Boru hattını çalıştırmadan önce, Node ve JVM sürümlerimizi kontrol etmemiz gerekir. Bunları Jenkinsfile'ın gerektirdiği şekilde yapılandırmalıyız.

Bu boru hattında, “jdk ‘jdk17’” ifadesi JDK 17'nin Jenkins sunucusunda yüklü olduğunu ve boru hattının bu JDK sürümünü kullanacağını gösterir. Benzer şekilde, “nodejs ‘node16’” ifadesi, Jenkins sunucusunda Node.js sürüm 16'nın yüklü olduğunu ve boru hattının bu sürümü kullanacağını gösterir.


>>> Jenkinsde yüklenebilecek eklentiler bölümünden "NodeJS" eklentisini yükleyelim
>>> Jenkinsde araçlar bölümünden "NodeJS 16.20.2" ekleyelim 
>>> Jenkinsde araçlar bölümünden "JDK" ekleyelim. buraya JAVA_HOME değişkenine jenkins serverdaki bu yolu verelim "/usr/lib/jvm/java-17-openjdk-amd64" ve kaydedelim.


## 15- Jenkins pipeline oluşturma

  >>> "Netfilix" pipelineı seçelim "Configure" tıklayalım. Aşağıdaki pipeline yapıştıralım:
````sh
  pipeline{
    agent any
    tools{
        jdk 'jdk17'
        nodejs 'node16'
    }
    environment {
        SCANNER_HOME=tool 'sonar-scanner'
    }
    stages {
        stage('clean workspace'){
            steps{
                cleanWs()
            }
        }
        stage('Checkout from Git'){
            steps{
                git branch: 'main', url: 'https://github.com/foriinji/Devops-Security-Projects.git'
            }
        }
        stage("Sonarqube Analysis "){
            steps{
                withSonarQubeEnv('sonar-server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Netflix \
                    -Dsonar.projectKey=Netflix '''
                }
            }
        }
        stage("quality gate"){
           steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'Sonar-token' 
                }
            } 
        }
        stage('Install Dependencies') {
            steps {
                sh "npm install"
            }
        }
    }
    post {
     always {
        emailext attachLog: true,
            subject: "'${currentBuild.result}'",
            body: "Project: ${env.JOB_NAME}<br/>" +
                "Build Number: ${env.BUILD_NUMBER}<br/>" +
                "URL: ${env.BUILD_URL}<br/>",
            to: 'mecit.tuksoy@gmail.com',
            attachmentsPattern: 'trivyfs.txt,trivyimage.txt'
        }
    }
}
````


>>> Bu işlem hattı, bir Java projesi için GitHub deposundan kod alır, bağımlılıkları yükler, SonarQube analizini gerçekleştirir, kalite kapısını bekler ve son olarak bir e-posta bildirimi gönderir.

>>> "Build Now" tıklayıp pipelineı takip edebiliriz. Başarılı mesajı maile gelecektir.

## 16- OWASP Bağımlılık Kontrol Eklentilerini Yükleyin

  1- Jenkins'i Yönet → Eklentiler → Yüklenebilir eklentiler → "OWASP Bağımlılık Kontrolü" yükle

  2- Jenkins'i Yönet → Araçlar → Dependency-Check kurulumları → Dependency-Check ekle
  "Name" = DP-Check
  "Install automatically" = Install from github.com
  "Version" = son versionu seçelim
  kaydet


>>> Pipelinea giderek configure edip pipelinea aşağıdaki adımı ekliyoruz:
 
````sh
        stage('OWASP FS SCAN') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage('TRIVY FS SCAN') {
            steps {
                sh "trivy fs . > trivyfs.txt"
            }
        }
````

## 17- Docker Görüntülerini Oluşturma, Gönderme ve Dağıtma

  1- Bu adıma başlamadan önce uygulamamızın çalışması için bir API anahtarı edinmemiz gerekiyor. https://www.themoviedb.org/ web sitesine kayıt olalım ve bir API anahtarı oluşturalım.

  2- ayarlar > API > oluştur > Developer > kabul et > ilgili yerleri doldurup API anahtarını alıyorum.

  3- jenkins kullanıcısına geçip manual olarak uygulamayı test etmek için:

  ````sh
  sudo su - jenkins 
  cd /workspace/Netflix/ 
  ls 
  cat Dockerfile
  ````
  ````sh
  docker build --build-arg TMDB_V3_API_KEY=<API_anahtarınızı_buraya_kaydedin> -t netflix-clone .
  ````

  ````sh
  docker run --name netflix-clone-website --rm -d -p 8081:80 netflix-clone
  ````
  
  >>>> public-ip:8081 ile uygulamayı görebiliriz. 

  4- Uygulama başarılı bir şekilde çalıştığını gördüğümüze göre şimdi image ve containerı silebilriz.
  ````sh
  docker rm -f netflix-clone-website 
  docker rmi netflix-clone
  ````



## 18- Jenkins ayarlarına devam:

  1- Jenkinsi yönet > Eklentiler > Yüklenebilir eklentiler: aşağıdakileri yükleyelim.

    Docker
    Docker Commons
    Docker Pipeline
    Docker API
    docker-build-step
   
   2- Jenkins'i Yönet > Araçlar > Docker kurulumları
   "Name"= docker
   "Install automatically"
    Download from docker.com
    "Docker version" = latest
    kaydet

   3- Jenkins'i Yönet > Credentials > System > Global credentials (unrestricted)
   Kind = Username with password
   Username = dockerhub kullanıcı adınızı girin
   Password = dockerhub tokenınızı girin
   ID = bir isim verin "docker" benimki pipelineda kullanacağız
   create

   4- Jenkins'de Netfilix pipelinea aşağıdaki kodları yapıştırıyoruz. 

````sh
pipeline{
    agent any
    tools{
        jdk 'jdk17'
        nodejs 'node16'
    }
    environment {
        SCANNER_HOME=tool 'sonar-scanner'
    }
    stages {
        stage('clean workspace'){
            steps{
                cleanWs()
            }
        }
        stage('Checkout from Git'){
            steps{
                git branch: 'main', url: 'https://github.com/foriinji/Devops-Security-Projects.git'
            }
        }
        stage("Sonarqube Analysis "){
            steps{
                withSonarQubeEnv('sonar-server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Netflix \
                    -Dsonar.projectKey=Netflix '''
                }
            }
        }
        stage("quality gate"){
           steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'Sonar-token' 
                }
            } 
        }
        stage('Install Dependencies') {
            steps {
                sh "npm install"
            }
        }
        // stage('OWASP FS SCAN') {
        //     steps {
        //         dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
        //         dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
        //     }
        // }
        stage('TRIVY FS SCAN') {
            steps {
                sh "trivy fs . > trivyfs.txt"
            }
        }
        stage("Docker Build & Push"){
            steps{
                script{
                   withDockerRegistry(credentialsId: 'docker', toolName: 'docker'){   
                       sh "docker build --build-arg TMDB_V3_API_KEY=<write_your_TMDB_api_key> -t netflix ."
                       sh "docker tag netflix mecit35/netflix:latest "
                       sh "docker push mecit35/netflix:latest "
                    }
                }
            }
        }
        stage('Deploy to container'){
            steps{
                sh 'docker rm -f netflix || true'
                sh 'docker run -d --name netflix -p 8081:80 mecit35/netflix:latest'
            }
        }
        stage('Check Application Status') {
            steps {
                script {
                    def response = sh(script: "curl -s -o /dev/null -w \"%{http_code}\" http://jenkins-server-public-ip:8081", returnStdout: true).trim()
                    if (response == '200') {
                        echo "Application is running successfully."
                    } else {
                        error "Application is not running. HTTP response code: ${response}"
                    }
                }
            }
        }
        stage("TRIVY"){
            steps{
                sh "trivy image mecit35/netflix:latest > trivyimage.txt" 
            }
        }
    }
    post {
     always {
        emailext attachLog: true,
            subject: "'${currentBuild.result}'",
            body: "Project: ${env.JOB_NAME}<br/>" +
                "Build Number: ${env.BUILD_NUMBER}<br/>" +
                "URL: ${env.BUILD_URL}<br/>",
            to: 'mecit.tuksoy@gmail.com',
            attachmentsPattern: 'trivyfs.txt,trivyimage.txt'
        }
    }
}
````

