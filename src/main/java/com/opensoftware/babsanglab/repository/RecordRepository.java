package com.opensoftware.babsanglab.repository;

import com.opensoftware.babsanglab.domain.Record;
import com.opensoftware.babsanglab.domain.User;
import org.springframework.cglib.core.Local;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface RecordRepository extends JpaRepository<Record,Long> {
    List<Record> findByUser(User user);
    @Query("SELECT r FROM Record r WHERE r.user = :user AND r.date = :date")
    List<Record> findByUserAndDate(@Param("user") User user, @Param("date") LocalDate date);
}
