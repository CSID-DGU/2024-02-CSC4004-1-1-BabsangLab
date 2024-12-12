package com.opensoftware.babsanglab.repository;

import com.opensoftware.babsanglab.domain.Record;
import com.opensoftware.babsanglab.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUserId(String userId);
    Optional<User> findByName(String name);
    Optional<User> findByUserIdAndPassword(@Param("userId") String userId, @Param("password") String password);
}
