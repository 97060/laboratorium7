---
# Laboratorium 7 - Zadanie P7.3. 
### Autor: Michał Grabowiec
---

### 1. Dockerfile oraz skrypt pluto.sh
**&ensp;Treść pliku Dockerfile**
```dockerfile
FROM alpine:latest
RUN apk add --no-cache bash
ADD pluto.sh /
RUN chmod 755 /pluto.sh
ENTRYPOINT ["bash", "pluto.sh"]
```
Dockerfile wykorzystuje obraz bazowy alpine. Dodatkowo instalowany jest bash, potrzebny do wykonania skryptu pluto.sh. Nadawane są potrzebne uprawnienia do wykonania skryptu, a następnie jest on ustawiany jako ENTRYPOINT.

**Skrypt pluto.sh**
```bash
#!/bin/bash
touch /logi/info.log
echo "Data utworzenia kontenera: $(date)" >> /logi/info.log
echo "Dostępna pamięć: $(grep MemTotal /proc/meminfo)" >> /logi/info.log
echo "Limit pamięci kontenera w bajtach: $(cat /sys/fs/cgroup/memory/memory.limit_in_bytes)" >> /logi/info.log
sleep infinity
```

Skrypt pluto.sh tworzy plik info.log w katalogu logi. Następnie do pliku dopisywane są informacje o dacie wykonania skryptu(utworzenia kontenera), dostępnej pamięci oraz o ilości przydzielonej pamięci podczas uruchamiania kontenera. 

### 2. Zbudowanie obrazu lab5docker
**Polecenie** 
```
docker build -t lab5docker .
```
**Wynik użytego polecenia** 

![image](https://user-images.githubusercontent.com/103126350/168440653-dbbd996d-8ca4-4b35-a7fe-23853629d7b1.png)

### 3. Utworzenie wolumenu RemoteVol

**Polecenie** 
```
docker volume create \
	--driver local \
	--opt type=cifs \
	--opt device=//192.168.1.120/logi \
	--opt o=addr=192.168.1.120,username=michal,password=*****,file_mode=0777,dir_mode=0777 \
	--name RemoteVol
```
Na potrzeby sprawozdania hasło zostało zastąpione znakiem * .

**Wynik polecenia inspect dla wolumenu** 

![image](https://user-images.githubusercontent.com/103126350/168440793-6ec71409-94d6-4441-8884-ee2e33752242.png) 

Systemem macieżystym jest system Windows. Używany jest sterownik local, który ma wbudowaną obsługę protokołu CIFS. Parametry określają ścieżkę do pliku, adres IP udziału, uprawnienia do folderu oraz użytkownika i hasło.

**Udostępniony udział sieciowy**

![image](https://user-images.githubusercontent.com/103126350/168440863-4d25c39d-3e1b-4303-b409-004838b8fa02.png)


**Tryb działania sieci dla maszyny wirtualnej - tryb mostkowania**

![image](https://user-images.githubusercontent.com/103126350/168440873-d7226cdf-e093-4152-bbec-a2fcf465ba1a.png)


### 4. Uruchomienie kontenera alpine4 

**Polecenie** 
```
docker run --name alpine4 -m 512m  -it --mount source=RemoteVol,target=/logi lab5docker
```

### 5. Potwierdzenie działania wykonanego zadania

**W katalogu logi na systemie macierzystym pojawił się plik** `info.log` **z zadaną treścią**

![image](https://user-images.githubusercontent.com/103126350/168441264-0da715c4-4ed1-4a92-83d0-b990a2679cd7.png)

**Wynik polecenia** `docker inspect alpine4` **potwierdzający ograniczenie RAM do wartości 512 MB**

![image](https://user-images.githubusercontent.com/103126350/168441537-95b81706-dcb9-44bb-b398-949f51731a66.png)

**Wynik polecenia** `docker stats alpine4` **potwierdzający ograniczenie RAM do wartości 512 MB**
![image](https://user-images.githubusercontent.com/103126350/168441735-63ccfbb6-6d32-4bb3-a1b8-cf6736c86fee.png)


### 6. Wykorzystanie narzędzia `CADVISOR` 

**Uruchomienie narzędzia `CADVISOR`**

![image](https://user-images.githubusercontent.com/103126350/168441717-21b18dd0-6a57-4b6f-9ca0-641a4caac635.png)


**Polecenie uruchamiające kontener z CADVISOREM**
```
VERSION=v0.39.3
sudo docker run \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  --publish=8080:8080 \
  --detach=true \
  --name=cadvisor \
  --privileged \
  --device=/dev/kmsg \
  gcr.io/cadvisor/cadvisor:$VERSION
  ```
Narzędzie `CADVISOR` po uruchomieniu dostępne jest w przeglądarce pod adresem `localhost:8080`.

**Funkcjonalność CADVISOR**

![image](https://user-images.githubusercontent.com/103126350/168441871-a9027ba4-70ea-49f7-9cd8-d4318465f035.png)

Narzędzie `CADVISOR` pozwala w ławty sposób uzyskać wiele informacji o wszystkich uruchomionych kontenerach. Poniżej widać potwierdzenie ograniczenia pamięci RAM dla kontenera alpine4 do wartośći 512MB.

![image](https://user-images.githubusercontent.com/103126350/168441900-9721ee54-3c08-4fe3-a8cc-da50dbcab24b.png)

Poza tym CADVISOR pozwala monitorować inne parametry takie jak zużycie zasobów (pamięć, CPU) przez kontener, uruchomione procesy, ruch sieciowy, informację o limicie pamięci lub ilości używanych rdzeni
procesora. 

![image](https://user-images.githubusercontent.com/103126350/168441912-26f8e178-82be-4a1e-8b74-7b62a67eba46.png)

---






  







 
