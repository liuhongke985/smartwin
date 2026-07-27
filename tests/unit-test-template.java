// SmartWin Unit Test Template
// Copy this template to create new unit tests
// Naming convention: {ClassName}Test.java

package com.smartwin.{module}.service;

import com.smartwin.{module}.dto.{Entity}DTO;
import com.smartwin.{module}.dto.{Entity}Request;
import com.smartwin.{module}.entity.{Entity};
import com.smartwin.{module}.exception.{Entity}NotFoundException;
import com.smartwin.{module}.repository.{Entity}Repository;
import com.smartwin.{module}.service.impl.{Entity}ServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.*;

/**
 * Unit test template for Service layer.
 * Replace {Entity} with the actual entity name (e.g., DataAsset).
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("{Entity}Service Unit Tests")
class {Entity}ServiceTest {

    @Mock
    private {Entity}Repository repository;

    @InjectMocks
    private {Entity}ServiceImpl service;

    private {Entity} testEntity;
    private {Entity}Request testRequest;

    @BeforeEach
    void setUp() {
        testEntity = {Entity}.builder()
                .id(1L)
                .name("Test {Entity}")
                .status(1)
                .build();

        testRequest = {Entity}Request.builder()
                .name("New {Entity}")
                .build();
    }

    // =========================================================
    // Test Group: getById
    // =========================================================
    @Nested
    @DisplayName("getById()")
    class GetByIdTests {

        @Test
        @DisplayName("should return entity when it exists")
        void getById_existingEntity_returnsEntityDTO() {
            // Arrange
            when(repository.findById(1L)).thenReturn(Optional.of(testEntity));

            // Act
            {Entity}DTO result = service.getById(1L);

            // Assert
            assertThat(result).isNotNull();
            assertThat(result.getId()).isEqualTo(1L);
            assertThat(result.getName()).isEqualTo("Test {Entity}");
            verify(repository, times(1)).findById(1L);
        }

        @Test
        @DisplayName("should throw NotFoundException when entity does not exist")
        void getById_nonExistingEntity_throwsNotFoundException() {
            // Arrange
            when(repository.findById(anyLong())).thenReturn(Optional.empty());

            // Act & Assert
            assertThatThrownBy(() -> service.getById(999L))
                    .isInstanceOf({Entity}NotFoundException.class)
                    .hasMessageContaining("999");
            verify(repository, times(1)).findById(999L);
        }
    }

    // =========================================================
    // Test Group: create
    // =========================================================
    @Nested
    @DisplayName("create()")
    class CreateTests {

        @Test
        @DisplayName("should create entity with valid request")
        void create_validRequest_returnsCreatedEntityDTO() {
            // Arrange
            when(repository.save(any({Entity}.class))).thenReturn(testEntity);

            // Act
            {Entity}DTO result = service.create(testRequest);

            // Assert
            assertThat(result).isNotNull();
            assertThat(result.getName()).isEqualTo(testEntity.getName());
            verify(repository, times(1)).save(any({Entity}.class));
        }

        @Test
        @DisplayName("should throw exception when name is null")
        void create_nullName_throwsIllegalArgumentException() {
            // Arrange
            {Entity}Request invalidRequest = {Entity}Request.builder()
                    .name(null)
                    .build();

            // Act & Assert
            assertThatThrownBy(() -> service.create(invalidRequest))
                    .isInstanceOf(IllegalArgumentException.class);
            verify(repository, never()).save(any());
        }
    }

    // =========================================================
    // Test Group: update
    // =========================================================
    @Nested
    @DisplayName("update()")
    class UpdateTests {

        @Test
        @DisplayName("should update entity when it exists")
        void update_existingEntity_returnsUpdatedEntityDTO() {
            // Arrange
            when(repository.findById(1L)).thenReturn(Optional.of(testEntity));
            when(repository.save(any({Entity}.class))).thenReturn(testEntity);

            // Act
            {Entity}DTO result = service.update(1L, testRequest);

            // Assert
            assertThat(result).isNotNull();
            verify(repository).findById(1L);
            verify(repository).save(any({Entity}.class));
        }
    }

    // =========================================================
    // Test Group: delete
    // =========================================================
    @Nested
    @DisplayName("delete()")
    class DeleteTests {

        @Test
        @DisplayName("should soft-delete entity when it exists")
        void delete_existingEntity_marksAsDeleted() {
            // Arrange
            when(repository.findById(1L)).thenReturn(Optional.of(testEntity));
            when(repository.save(any())).thenReturn(testEntity);

            // Act
            service.delete(1L);

            // Assert
            verify(repository).findById(1L);
            verify(repository).save(any({Entity}.class));
        }
    }
}
