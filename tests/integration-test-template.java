// SmartWin Integration Test Template
// Naming convention: {ClassName}IT.java (IT = Integration Test)

package com.smartwin.{module}.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.smartwin.{module}.dto.{Entity}Request;
import com.smartwin.{module}.dto.{Entity}DTO;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import static org.hamcrest.Matchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Integration test template for Controller layer.
 * Uses MockMvc for HTTP testing against real application context.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional  // Rollback after each test
@DisplayName("{Entity} API Integration Tests")
class {Entity}ControllerIT {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    private static final String BASE_URL = "/api/v1/{entities}";

    private {Entity}Request validRequest;

    @BeforeEach
    void setUp() {
        validRequest = {Entity}Request.builder()
                .name("Test Integration {Entity}")
                .description("Integration test entity")
                .build();
    }

    @Test
    @DisplayName("GET /api/v1/{entities} - should return list with pagination")
    @WithMockUser(roles = "DATA_ANALYST")
    void listEntities_authenticatedUser_returnsPagedResult() throws Exception {
        mockMvc.perform(get(BASE_URL)
                        .param("page", "1")
                        .param("pageSize", "10")
                        .contentType(MediaType.APPLICATION_JSON))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.items").isArray())
                .andExpect(jsonPath("$.data.total").isNumber());
    }

    @Test
    @DisplayName("POST /api/v1/{entities} - should create entity with valid data")
    @WithMockUser(roles = "DATA_MANAGER")
    void createEntity_validRequest_returnsCreatedEntity() throws Exception {
        ResultActions result = mockMvc.perform(post(BASE_URL)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(validRequest)))
                .andDo(print())
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.code").value(201))
                .andExpect(jsonPath("$.data.id").isNumber())
                .andExpect(jsonPath("$.data.name").value(validRequest.getName()));
    }

    @Test
    @DisplayName("POST /api/v1/{entities} - should return 400 when name is missing")
    @WithMockUser(roles = "DATA_MANAGER")
    void createEntity_missingName_returns400() throws Exception {
        {Entity}Request invalidRequest = {Entity}Request.builder().build();

        mockMvc.perform(post(BASE_URL)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(invalidRequest)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value(400));
    }

    @Test
    @DisplayName("GET /api/v1/{entities}/{id} - should return 404 for non-existing entity")
    @WithMockUser(roles = "DATA_ANALYST")
    void getEntity_nonExisting_returns404() throws Exception {
        mockMvc.perform(get(BASE_URL + "/999999"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code").value(404));
    }

    @Test
    @DisplayName("DELETE /api/v1/{entities}/{id} - should return 401 for unauthenticated request")
    void deleteEntity_unauthenticated_returns401() throws Exception {
        mockMvc.perform(delete(BASE_URL + "/1"))
                .andExpect(status().isUnauthorized());
    }
}
