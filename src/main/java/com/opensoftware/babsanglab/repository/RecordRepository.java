package com.opensoftware.babsanglab.repository;

import com.opensoftware.babsanglab.domain.Record;
import com.opensoftware.babsanglab.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RecordRepository extends JpaRepository<Record,Long> {


    List<Record> findByUser(User user);
}
