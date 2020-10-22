FROM ironmansoftware/universal:latest
LABEL description="Universal - The ultimate platform for building web-based IT Tools" 

EXPOSE 5000
VOLUME ["/data"]
RUN /usr/bin/pwsh -interactive -command Set-PSRepository PSGallery -InstallationPolicy Trusted
RUN /usr/bin/pwsh -interactive -command Install-Module dbatools
RUN mkdir /usr/secrets
COPY ./secrets.json /usr/secrets/secrets.json
ADD Scripts/* ./data/Repository/
ADD Dashboards/* ./data/Repository/
ADD scripts.ps1 ./data/Repository/.universal/scripts.ps1
ADD schedules.ps1 ./data/Repository/.universal/schedules.ps1
ADD dashboards.ps1 ./data/Repository/.universal/dashboards.ps1
ADD dashboards.components.ps1 ./data/Repository/.universal/dashboards.components.ps1
ENV Data__RepositoryPath ./data/Repository
ENV Data__ConnectionString ./data/database.db
ENV UniversalDashboard__AssetsFolder ./data/UniversalDashboard 
ENV Logging__Path ./data/logs/log.txt
ENTRYPOINT ["./home/Universal/Universal.Server"]