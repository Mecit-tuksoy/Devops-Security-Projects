# "Creating and Securing Netflix Clone on GCP Using DevOps Tools (SonarQube, OWASP, Trivy, Jenkins, Docker, Kubernetes, Prometheus, Grafana)"

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

<div align="center">
  <a href="http://netflix-clone-with-tmdb-using-react-mui.vercel.app/">
    <img src="./public/assets/netflix-logo.png" alt="Logo" width="100" height="32">
  </a>

  <h3 align="center">Netflix Clone</h3>

  <p align="center">
    <a href="https://netflix-clone-react-typescript.vercel.app/">View Demo</a>
    ·
    <a href="https://github.com/crazy-man22/netflix-clone-react-typescript/issues">Report Bug</a>
    ·
    <a href="https://github.com/crazy-man22/netflix-clone-react-typescript/issues">Request Feature</a>
  </p>
</div>

<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#prerequests">Prerequests</a>
    </li>
    <li>
      <a href="#which-features-this-project-deals-with">Which features this project deals with</a>
    </li>
    <li><a href="#third-party-libraries-used-except-for-react-and-rtk">Third Party libraries used except for React and RTK</a></li>
    <li>
      <a href="#contact">Contact</a>
    </li>
  </ol>
</details>

<br />

<div align="center">
  <img src="./public/assets/home-page.png" alt="Logo" width="100%" height="100%">
  <p align="center">Home Page</p>
  <img src="./public/assets/mini-portal.png" alt="Logo" width="100%" height="100%">
  <p align="center">Mini Portal</p>
  <img src="./public/assets/detail-modal.png" alt="Logo" width="100%" height="100%">
  <p align="center">Detail Modal</p>
  <img src="./public/assets/grid-genre.png" alt="Logo" width="100%" height="100%">
  <p align="center">Grid Genre Page</p>
  <img src="./public/assets/watch.png" alt="Logo" width="100%" height="100%">
  <p align="center">Watch Page with customer contol bar</p>
</div>


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
    1-“prometheus” adında bir sistem kullanıcısı oluşturu`yoruz
  ````sh
  sudo useradd \ 
    --system \ 
    --no-create-home \ 
    --shell /bin/false prometheus
  ````  
    2- 
    - Prometheus dosyasını indir
````sh
wget https://github.com/prometheus/prometheus/releases/download/v2.51.2/prometheus-2.51.2.linux-amd64.tar.gz
````
  
    - Tar dosyasını açıyoruz:
````sh 
tar -xvf prometheus-2.51.2.linux-amd64.tar.gz
````
   
    - Prometheus verileri ve yapılandırma dosyaları için dizinler oluştur
 ````sh
 sudo mkdir -p /data /etc/prometheus
````
    - Prometheus ikili dosyalarını /usr/local/bin/ dizinine taşı 
````sh 
cd prometheus-2.51.2.linux-amd64/ 
sudo mv prometheus promtool /usr/local/bin/
````
    - Konsol şablonlarını ve kitaplıklarını /etc/prometheus/ dizinine taşı
````sh
sudo mv consoles/ console_libraries/ /etc/prometheus/
````
    - Prometheus yapılandırma dosyasını /etc/prometheus/ dizinine taşı
````sh
sudo mv prometheus.yml /etc/prometheus/prometheus.yml
````
    - Prometheus yapılandırma ve veri dizinlerinin sahipliğini 'prometheus' kullanıcısına değiştir
````sh
sudo chown -R prometheus:prometheus /etc/prometheus/ /data/
````
    - Ana dizine geri dön 
````sh
cd 
````
    - İndirilen Prometheus arşiv dosyasını kaldır 
````sh
rm -rf prometheus-2.51.2.linux-amd64.tar.gz
````
    - Prometheus sürümünü kontrol et
````sh
prometheus --version
````
    - Prometheus yardımını görüntüle
````sh
prometheus --help
````
    3-
    Prometheus için systemd yapılandırması, Prometheus'un Linux sistemlerinde bir hizmet olarak çalışmasını
    sağlayarak sistem yeniden başlatıldığında veya hizmetin yönetilmesi gerektiğinde otomatik olarak 
    başlamasını sağlar.

````sh
     sudo nano /etc/systemd/system/prometheus.service
````
````sh
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
````sh
    sudo systemctl enable prometheus 
    sudo systemctl start prometheus 
    sudo systemctl status prometheus
````

## 6- Node Exporter'u İzleme Sunucusuna Kurun bunun için:
     1- “node_exporter” adında bir sistem kullanıcısı oluşturu`yoruz
````sh
sudo useradd \
--system \
--no-create-home \
--shell /bin/false node_exporter
````
     2- 
    - Node Exporter dosyasını indir
````sh
wget https://github.com/prometheus/node_exporter/releases/download/v1.8.0/node_exporter-1.8.0.linux-amd64.tar.gz
````  
    - Tar dosyasını açıyoruz:
````sh
tar -xvf node_exporter-1.8.0.linux-amd64.tar.gz
````   
    - Node Exporter dosyasını /usr/local/bin/ dizinine taşı 
````sh
sudo mv node_exporter-1.8.0.linux-amd64/node_exporter /usr/local/bin/
````
    - İndirilen Node Exporter arşiv dosyasını kaldır 
````sh
rm -rf node_exporter*
````
    - Node Exporter sürümünü kontrol et
````sh
node_exporter --version
````
    - Node Exporter yardımını görüntüle
````sh
node_exporter --help
````

3-
Node Exporter için systemd yapılandırması, Node Exporter'un Linux sistemlerinde bir hizmet olarak çalışmasını sağlayarak sistem yeniden başlatıldığında veya hizmetin yönetilmesi gerektiğinde otomatik olarak başlamasını sağlar.

````sh
sudo nano /etc/systemd/system/node_exporter.service
````

````sh

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

````sh
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
sudo systemctl status node_exporter
````

## 7- Prometheus için Statik Hedef Oluşturma
    
    1- prometheus.yml konfigürasyon dosyasını açıyoruz.
````sh
sudo nano /etc/prometheus/prometheus.yml
````

    2- prometheus.yml dosyasının en altına bunu yapıştır:
````sh
    - job_name: node_export
      static_configs:
        - targets: ["localhost:9100"]
````

    3- Kontrol için:
````sh
promtool check config /etc/prometheus/prometheus.yml
curl -X POST http://localhost:9090/-/reload
````

## 8- Jenkins Server'a Node Exporter Kurulumu ve Statik Hedef Oluşturma

    1- 
````sh
sudo useradd --system --no-create-home --shell /bin/false node_exporter
````

    2- Dosyayı indir
````sh
wget https://github.com/prometheus/node_exporter/releases/download/v1.8.0/node_exporter-1.8.0.linux-amd64.tar.gz 
````
    3- Arşiv dosyasını çıkar
````sh
tar -xvf node_exporter-1.8.0.linux-amd64.tar.gz
````
    4- İlgili yere taşı.
````sh
sudo mv node_exporter-1.8.0.linux-amd64/node_exporter /usr/local/bin/
````
    5- Gereksiz dosyaları sil
````sh
rm -rf node_exporter*
````
    6- Kurulumu kontrol et.
````sh
node_exporter --version
````
    7- Service dosyasını düzenle.
````sh
sudo nano /etc/systemd/system/node_exporter.service
````
````sh
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
````
````sh
# start and enable node_exporter
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
sudo systemctl status node_exporter
````

## 9- Monitoring server'da prometheus.yml configürasyon dosyasına jenkins serverı hedef olarak ekliyoruz: 
    
````sh
sudo nano /etc/prometheus/prometheus.yml 
````

````sh
- job_name: node_export_jenkins
    static_configs:
      - targets: ["jenkins-server-publicIP:9100"]
````

    Kontrol için:
````sh
promtool check config /etc/prometheus/prometheus.yml
curl -X POST http://localhost:9090/-/reload 
````

## 10- Monitörig serverda Grafana Kurulumu ve Yapılandırması:

    1- Install necessary packages for adding Grafana repository
````sh
sudo apt-get install -y apt-transport-https software-properties-common
````
    2- Add Grafana GPG key to verify package integrity
````sh
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
````
    3- Add Grafana repository to APT sources
````sh
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
````
    4- Update package lists to include Grafana packages
````sh
sudo apt-get update
````
    5- Install Grafana
````sh
sudo apt-get -y install grafana
````
    6- Enable Grafana service to start on boot
````sh
sudo systemctl enable grafana-server
````
    7- Start Grafana service
````sh
sudo systemctl start grafana-server
````
    8- Check status of Grafana service
````sh
sudo systemctl status grafana-server
````
    9- Kurulu başarılı olduktan sonra monitöring serverin public ipsi ile 3000 portundan Grafana'ya giriş yapıyoruz 

    10- Kullanıcı adı ve şifre "admin" olarak devam edip yeni şifre belirliyoruz.

    11- "Data Sources" olarak Prometheus seçiyoruz. Buraya monitöring serverın public ipsini ekliyoruz.

    12- Dashboarts kısmından güzel bir dashbort import ediyoruz. Ben "1860" kullandım.


## 11- Prometheus Eklentisinin Jenkins'e Kurulumu ve Entegrasyonu:

    1- Jenkins_server_public_ip :8080 ile jenkinse bağlan
    
    2- “Jenkins’i Yönet” → “Eklentileri Yönet” → “Kullanılabilir Eklentiler”e gidin.

    3- Burada arama çubuğuna "prometheus" yaz. ilk çıkan eklentiyi indir.

    4- Jenkin'i yeniden başlat.

    5- http://Jenkins_server_public_ip:8080/prometheus   adresinden JSON formatında metrikler görebiliyorsanız, endpoint çalışıyor demektir. Eğer çalışmıyorsa, Jenkins'teki eklentiyi kontrol edin.


## 12- Monitöring serverda prometheus.yml konfigürasyon dosyasına jenkinsi ekle

    1- sudo nano /etc/prometheus/prometheus.yml

    2-
````sh 
    - job_name: jenkins
      metrics_path: "/prometheus"
      static_configs:
        - targets: ["<jenkins-ip>:8080"]
````
    3- Kontrol için:
````sh
promtool check config /etc/prometheus/prometheus.yml
curl -X POST http://localhost:9090/-/reload
````

## 13- Jenkins ile E-posta Entegrasyonunu Ayarlama ve Eklentiyi Yükleme

    1- Burada, e-posta gönderebilmek için Gmail hesabımızdan bir uygulama şifresi almamız gerekiyor. 
    Gmail hesabımıza gidelim ve şifreyi üretelim.
    Bu işlemlerin yapılabilmesi için iki adımlı doğrulamanın etkinleştirilmesi gerekmektedir.
    Bu işlemi yaptıktn sonra "uygulama şifreleri"ne gidin. Bir ad belirleyin "jenkins" ve oluştur deyin.
    Gelen şifreyi kaydedin.

    2- Jenkinse girerek Jenkins'i Yönet > Sistem > E-posta Bilgilendirmesi  bölümüne geliyoruz.
    Aşağıdaki bölümleri dolduralım.

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


## 14- Jenkins İşi ​​Oluşturma

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



## 15- Manage Jenkins'te Sonar Sunucusunu Yapılandırma

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
                git branch: 'main', url: 'https://github.com/Mecit-tuksoy/Devops-Security-Projects.git'
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


>>> Bu işlem hattı, bir Java projesi için GitHub deposundan kod alır, bağımlılıkları yükler, SonarQube analizini gerçekleştirir, SonarQube kalite kapısı kontrolü yapar. Kalite kapısı kriterlerini karşılayıp karşılamadığına göre pipeline'ın devam edip etmeyeceğine karar verir ve son olarak bir e-posta bildirimi gönderir.

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
Bu iki aşama, projenin güvenlik taramalarını gerçekleştirerek, hem bağımlılık seviyesinde (OWASP Dependency-Check) hem de dosya sistemi seviyesinde (Trivy) güvenlik açıklarını tespit eder. Elde edilen raporlar, pipeline'ın devamında değerlendirilebilir ya da inceleme için saklanabilir. 

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
                git branch: 'main', url: 'https://github.com/Mecit-tuksoy/Devops-Security-Projects.git'
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

Bu pipeline, Docker imajı oluşturma, etiketleme, Docker Hub'a push etme, container'da çalıştırma, uygulama durumunu kontrol etme ve Docker imajı için Trivy taraması yapmayı içerir. 
OWASP Dependency-Check taraması ve rapor oluşturma adımı uzun sürdüğü ve bir önceki pipelineda gösterildiği için bu aşamada yorum haline getirilmiştir.

## 19- Kubernetes Kurulumu

   1- 2 tane Ubuntu 20.04 LTS imajı ve e2-medium türünde sanal makine oluşturuyoruz. Master ve worker.

   2- Master makineye bağlanarak aşağıdaki betiği içeren "bir master.sh" dosyası oluşturuyoruz. İzinlerini ayarlayıp çalıştırıyoruz.

````sh
sudo nano master.sh
````

````sh
#!/bin/bash
# APT update
sudo apt update

# Installation of Kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Installation and configuration of Docker
sudo apt-get update
sudo apt-get install -y docker.io
sudo usermod -aG docker $USER
grep '^docker:' /etc/group; getent group docker
sudo chmod 777 /var/run/docker.sock

# System update and installation of necessary packages
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo mkdir -p /etc/apt/keyrings/
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Installation of Kubernetes
sudo apt-get update
sudo apt-get install -y kubelet=1.29.0-1.1 kubeadm=1.29.0-1.1 kubernetes-cni
sudo apt-mark hold kubelet kubeadm kubectl

# Starting and enabling Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Loading kernel modules and sysctl configuration
sudo tee /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

sudo tee /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

# Installation and configuration of Containerd
sudo apt update
sudo apt install -y containerd
sudo systemctl start containerd
sudo systemctl enable containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo systemctl restart containerd

# Checking the status of Containerd
echo "Installation completed!"
````
   
````sh
sudo chmod +x master.sh 
bash master.sh
````

   3- Kubernetes kümesinin ana makinemizde çalışabilmesi için gerekli temel bileşenleri kuralım.

````sh
sudo nano kubernetes.sh
````

````sh
#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

# Pull Kubernetes images
sudo kubeadm config images pull

# Initialize Kubernetes cluster
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=All

# Set up kubeconfig for the user
USER_HOME=$(eval echo ~$USER)
sudo mkdir -p $USER_HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $USER_HOME/.kube/config
sudo chown $USER:$USER $USER_HOME/.kube/config

# Apply Flannel pod network
sudo -i -u $USER kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml

# Apply Local Path Provisioner
sudo -i -u $USER kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.26/deploy/local-path-storage.yaml

# Set Local Path StorageClass as default
sudo -i -u $USER kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

echo "Kubernetes cluster setup complete!"
````

````sh
sudo chmod +x kubernetes.sh 
bash kubernetes.sh 
kubectl get no
````

   4- Şimdi workera bağlanalım ve kuruluma devam edelim. Workerda gerekli bileşenleri kurmak için masterda yaptığımıza benzer adımları takip edeceğiz.

````sh
sudo nano worker.sh
````

````sh
#!/bin/bash
# APT update
sudo apt update

# Installation of Kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Installation and configuration of Docker
sudo apt-get update
sudo apt-get install -y docker.io
sudo usermod -aG docker $USER
grep '^docker:' /etc/group; getent group docker
sudo chmod 777 /var/run/docker.sock

# System update and installation of necessary packages
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo mkdir -p /etc/apt/keyrings/
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Installation of Kubernetes
sudo apt-get update
sudo apt-get install -y kubelet=1.29.0-1.1 kubeadm=1.29.0-1.1 kubernetes-cni
sudo apt-mark hold kubelet kubeadm kubectl

# Starting and enabling Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Loading kernel modules and sysctl configuration
sudo tee /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

sudo tee /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

# Installation and configuration of Containerd
sudo apt update
sudo apt install -y containerd
sudo systemctl start containerd
sudo systemctl enable containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo systemctl restart containerd

# Checking the status of Containerd
echo "Installation completed!"
````

````sh
sudo chmod +x worker.sh 
./worker.sh
````

   5- Kubernetes work node'unu master'a bağlayalım. Eğer ek work node'lar oluşturursak, 
   bu şekilde master ile bağlantılarını sağlayabiliriz. Gerekli birleştirme komutunu almak için 
   master node ta aşağıdaki komutu çalıştıralım:

````sh
sudo kubeadm token create --print-join-command
````
>>> Gelen çıktıyı worker node a yapıştırıyoruz aşağıdaki gibi bir şey:

````sh
sudo kubeadm join 10.182.0.5:6443 --token u4rdkh.hz16x9z9lqy5ysrg --discovery-token-ca-cert-hash sha256:dd41f62822bc8b897d4a843eb4be1daf4426570318f9a28c827d88fcb4d7738b
````

>>> master node ta ````sh kubectl get no```` komutu ile worker node u görebiliriz.

## 20- Metriklerini izlemek için hem ana hem de çalışan düğümlere Node Exporter'ı yükleyelim 

````sh
sudo useradd \
--system \
--no-create-home \
--shell /bin/false node_exporter
````

````sh
wget https://github.com/prometheus/node_exporter/releases/download/v1.8.0/node_exporter-1.8.0.linux-amd64.tar.gz 
tar -xvf node_exporter-1.8.0.linux-amd64.tar.gz 
sudo mv node_exporter-1.8.0.linux-amd64/node_exporter /usr/local/bin/
rm -rf node_exporter* 
node_exporter --version
````

````sh
sudo nano /etc/systemd/system/node_exporter.service
````

````sh
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

````sh
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
sudo systemctl status node_exporter
````

>>> Monitoring servera bağlanarak prometheus.yml konfigürasyon dosyasını ekleme yapıyoruz

````sh
sudo nano /etc/prometheus/prometheus.yml 
````

```bash
- job_name: master
    static_configs:
      - targets: ["master_public_ip:9100"]

- job_name: worker
    static_configs:
      - targets: ["worker_public_ip:9100"]
```
````sh
promtool check config /etc/prometheus/prometheus.yml
curl -X POST http://localhost:9090/-/reload
````

## 21- Jenkins sunucusuna kubectl kurulumu:

   1- Bu aşamada Jenkins ile Kubernetes kümemiz arasında bir bağlantı kurmamız gerekiyor.
   Jenkins'in Kubernetes kümesini yönetebilmesi için Jenkins sunucusuna kubectl yüklememiz gerekiyor.

````sh
sudo nano kube.sh
````
   
````sh
sudo apt update
sudo apt install curl -y
curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
````

````sh
sudo chmod +x kube.sh 
bash kube.sh
````

   2- Master nodeda /home/.kube klasörü altındaki "config" dosyasını bir yere kaydediyoruz.  ismini "secret-file.txt" yaptım.
   Bu dosyayı Kubernetes kimlik bilgisi bölümünde kullanıcağız.

   3- Jenkins'te Kubernetes'i yönetmek için Kubernetes eklentilerini indirip yüklemeniz gerekir. bunun için:

   Jenkins'i Yönet > Eklentiler > Yüklenebilecek eklentiler  bölümüne gidip aşağıdaki eklentileri ekliyoruz:
   Kubernetes Credential
   Kubernetes Client API
   Kubernetes
   Kubernetes CLI
   
   4- “Manage Jenkins” → “Manage Credentials” → Click on “Jenkins” global → “Add Credentials”.

   "Kind" = Secret file  
   "File" = secret-file.txt dosyasını seçiyoruz.
   "ID" = k8s
   creste

   5- Kubernetes için manifesto yaml dosyaları aşağıdaki gibi olacak:

>>>deployment.yml
````sh
apiVersion: apps/v1
kind: Deployment
metadata:
  name: netflix-app
  labels:
    app: netflix-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: netflix-app
  template:
    metadata:
      labels:
        app: netflix-app
    spec:
      containers:
      - name: netflix-app
        image: mecit35/netflix:latest
        ports:
        - containerPort: 80
````

>>> service.yml
````sh
apiVersion: v1
kind: Service
metadata:
  name: netflix-app
  labels:
    app: netflix-app
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30007
  selector:
    app: netflix-app
````


   6- "Netfilix" pipelinina kubernetes kümesinde deploy etmesi için aşağıdaki adımı ekliyoruz.

````sh
        stage('Deploy to kubernets'){
            steps{
                script{
                    dir('Kubernetes') {
                        withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'k8s', namespace: '', restrictKubeConfigAccess: false, serverUrl: '') {
                                sh 'kubectl apply -f deployment.yml'
                                sh 'kubectl apply -f service.yml'
                        }   
                    }
                }
            }
        }
````

 