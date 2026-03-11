package csd230.bookstore.controllers;

import csd230.bookstore.entities.MagazineEntity;
import csd230.bookstore.repositories.MagazineEntityRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Magazine REST API", description = "JSON API for managing magazines")
@RestController
@RequestMapping("/api/rest/magazines")
@CrossOrigin(origins = "*") // Allows your Vite React app to access this
public class MagazineRestController {

    private final MagazineEntityRepository magazineRepository;

    public MagazineRestController(MagazineEntityRepository magazineRepository) {
        this.magazineRepository = magazineRepository;
    }

    @Operation(summary = "Get all magazines as JSON")
    @GetMapping
    public List<MagazineEntity> all() {
        return magazineRepository.findAll();
    }

    @Operation(summary = "Get a single magazine by ID")
    @GetMapping("/{id}")
    public MagazineEntity getMagazine(@PathVariable Long id) {
        return magazineRepository.findById(id).orElseThrow();
    }

    @Operation(summary = "Create a new magazine")
    @PostMapping
    public MagazineEntity newMagazine(@RequestBody MagazineEntity newMagazine) {
        return magazineRepository.save(newMagazine);
    }

    @Operation(summary = "Update or Replace a magazine")
    @PutMapping("/{id}")
    public MagazineEntity replaceMagazine(@RequestBody MagazineEntity newMag, @PathVariable Long id) {
        return magazineRepository.findById(id)
                .map(mag -> {
                    // Inherited from PublicationEntity
                    mag.setTitle(newMag.getTitle());
                    mag.setPrice(newMag.getPrice());
                    mag.setCopies(newMag.getCopies());

                    // Specific to MagazineEntity
                    mag.setOrderQty(newMag.getOrderQty());
                    mag.setCurrentIssue(newMag.getCurrentIssue());

                    return magazineRepository.save(mag);
                })
                .orElseGet(() -> {
                    newMag.setId(id);
                    return magazineRepository.save(newMag);
                });
    }

    @Operation(summary = "Delete a magazine")
    @DeleteMapping("/{id}")
    public void deleteMagazine(@PathVariable Long id) {
        magazineRepository.deleteById(id);
    }
}