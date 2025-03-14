# gradle:7.3.1-jdk17 이미지를 기반으로 함
FROM krmp-d2hub-idock.9rum.cc/goorm/gradle:8.2.1-jdk17 AS builder

# 작업 디렉토리 설정
WORKDIR project

# Spring 소스 코드를 이미지에 복사
COPY /matgpt .

# gradle 빌드 시 proxy 설정을 gradle.properties에 추가
RUN echo "systemProp.http.proxyHost=krmp-proxy.9rum.cc\nsystemProp.http.proxyPort=3128\nsystemProp.https.proxyHost=krmp-proxy.9rum.cc\nsystemProp.https.proxyPort=3128" > /root/.gradle/gradle.properties

# gradle 초기화
RUN gradle init

# gradle wrapper를 프로젝트에 추가
RUN gradle wrapper

# gradlew를 이용한 프로젝트 필드
RUN chmod +x gradlew

# gradlew를 이용한 프로젝트 필드
RUN ./gradlew clean build -x test

FROM builder AS final
COPY --from=builder /home/gradle/project/build/libs/matgpt-0.0.1-SNAPSHOT.jar .

# DATABASE_URL을 환경 변수로 삽입
ENV DATABASE_URL=jdbc:mysql://mysql/matgpt_db




# 빌드 결과 jar 파일을 실행
CMD ["java", "-jar", "-Dspring.profiles.active=deploy", "matgpt-0.0.1-SNAPSHOT.jar"]