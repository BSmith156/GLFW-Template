CC := g++
SRC_DIR := src
SRC_FILES := $(wildcard $(SRC_DIR)/*.cpp)
OBJ_DIR := obj
OBJ_FILES := $(patsubst $(SRC_DIR)/%.cpp, $(OBJ_DIR)/%.o, $(SRC_FILES))
EXE := application

UNAME := $(shell uname)
ifeq ($(UNAME), Linux)
	LFLAGS := -lGL -lglfw
endif

all: $(EXE)

$(EXE): $(OBJ_FILES)
	$(CC) $^ -o $@ $(LFLAGS)

-include $(OBJ_FILES:.o=.d)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp | $(OBJ_DIR)
	$(CC) -c $(SRC_DIR)/$*.cpp -o $@
	$(eval d_file := $(patsubst %.o, %.d, $@))
	$(CC) -MM $(SRC_DIR)/$*.cpp > $(d_file)
	@mv -f $(d_file) $(d_file).tmp
	@sed -e 's|.*:|$@:|' < $(d_file).tmp > $(d_file)
	@cp -f $(d_file) $(d_file).tmp
	@sed -e 's/.*://' -e 's/\\$$//' < $(d_file).tmp | fmt -1 | \
		sed -e 's/^ *//' -e 's/$$/:/' >> $(d_file)
	@rm -f $(d_file).tmp

$(OBJ_DIR):
	mkdir $(OBJ_DIR)

clean:
	rm -rf $(OBJ_DIR)/ $(EXE)