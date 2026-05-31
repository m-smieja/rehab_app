package com.example.demo;

import com.example.demo.entities.Users;
import com.example.demo.repositories.UsersRepository;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class DataInitializer implements ApplicationRunner {

    private final UsersRepository usersRepository;

    public DataInitializer(UsersRepository usersRepository) {
        this.usersRepository = usersRepository;
    }

    @Override
    public void run(ApplicationArguments args) {
        // Seed tylko jeśli konto demonstracyjne trenera jeszcze nie istnieje
        if (usersRepository.findByEmail("trener@test.com") != null) {
            return;
        }

        // --- Trener demonstracyjny ---
        Users trener = new Users();
        trener.setEmail("trener@test.com");
        trener.setPassword("trener123");
        trener.setRole("TRENER");
        trener = usersRepository.save(trener);

        // --- Główne konto klienta demonstracyjnego ---
        Users klient = new Users();
        klient.setEmail("klient@test.com");
        klient.setPassword("klient123");
        klient.setRole("KLIENT");
        klient.setTrainer(trener);
        usersRepository.save(klient);

        // --- Pacjenci poglądowi przypisani do trenera ---
        List<String[]> pacjenci = List.of(
            new String[]{"marek.kowalski@demo.pl",     "demo1234"},
            new String[]{"anna.nowak@demo.pl",         "demo1234"},
            new String[]{"piotr.wisniewski@demo.pl",   "demo1234"},
            new String[]{"katarzyna.wojcik@demo.pl",   "demo1234"},
            new String[]{"tomasz.lewandowski@demo.pl", "demo1234"}
        );

        for (String[] dane : pacjenci) {
            Users p = new Users();
            p.setEmail(dane[0]);
            p.setPassword(dane[1]);
            p.setRole("KLIENT");
            p.setTrainer(trener);
            usersRepository.save(p);
        }

        System.out.println("[DataInitializer] Dane demonstracyjne załadowane.");
    }
}
