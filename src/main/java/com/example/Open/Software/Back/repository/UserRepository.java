package com.example.Open.Software.Back.repository;

import com.example.Open.Software.Back.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUserId(String user_id);
    Optional<User> findByUsername(String username);
}
