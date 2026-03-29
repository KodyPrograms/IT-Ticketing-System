package com.example.ticketing;

import java.net.URI;
import java.net.URISyntaxException;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class TicketingApplication {

	public static void main(String[] args) {
		applyKoyebDatabaseFallback();
		SpringApplication.run(TicketingApplication.class, args);
	}

	private static void applyKoyebDatabaseFallback() {
		if (hasText(System.getenv("SPRING_DATASOURCE_URL"))) {
			return;
		}

		String databaseUrl = System.getenv("DATABASE_URL");
		if (!hasText(databaseUrl)) {
			return;
		}

		try {
			URI uri = new URI(databaseUrl);
			String scheme = uri.getScheme();
			if (!"postgres".equalsIgnoreCase(scheme) && !"postgresql".equalsIgnoreCase(scheme)) {
				return;
			}

			StringBuilder jdbcUrl = new StringBuilder("jdbc:postgresql://")
				.append(uri.getHost());
			if (uri.getPort() != -1) {
				jdbcUrl.append(':').append(uri.getPort());
			}
			jdbcUrl.append(uri.getPath());
			if (hasText(uri.getQuery())) {
				jdbcUrl.append('?').append(uri.getQuery());
			}

			System.setProperty("spring.datasource.url", jdbcUrl.toString());

			if (!hasText(System.getenv("SPRING_DATASOURCE_USERNAME")) && hasText(uri.getUserInfo())) {
				String[] credentials = uri.getUserInfo().split(":", 2);
				if (credentials.length > 0 && hasText(credentials[0])) {
					System.setProperty("spring.datasource.username", credentials[0]);
				}
				if (credentials.length > 1 && hasText(credentials[1])) {
					System.setProperty("spring.datasource.password", credentials[1]);
				}
			}
		} catch (URISyntaxException ignored) {
			// If DATABASE_URL is malformed, Spring will fall back to its normal config path.
		}
	}

	private static boolean hasText(String value) {
		return value != null && !value.isBlank();
	}

}
