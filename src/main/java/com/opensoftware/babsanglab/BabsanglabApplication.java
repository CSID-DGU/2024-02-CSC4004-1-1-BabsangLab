package com.opensoftware.babsanglab;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration;

@SpringBootApplication (exclude = SecurityAutoConfiguration.class)
public class BabsanglabApplication {

	public static void main(String[] args) {
		SpringApplication.run(BabsanglabApplication.class, args);
	}

}
