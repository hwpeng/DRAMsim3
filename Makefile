export LD_LIBRARY_PATH := /mnt/users/ssd3/homes/huwan/tool/gcc-12.3.0/lib64:${LD_LIBRARY_PATH}

MEM = HBM2 HMC2
CAP = 4GB 8GB
CHA = 8 32
CYC = 200000

CONFIGS_DIR = new_configs
OUTPUT_DIR = output
TRACE_DIR = traces

$(OUTPUT_DIR):
	mkdir $@ || :

define GEN_TRACE
gen_trace.$(cha):
	python scripts/trace_gen.py -o $(TRACE_DIR) -f dramsim3 -s s -r 2000000 -n 2000000 -i 1 -p $(cha)
endef
$(foreach cha,$(CHA), \
  $(eval $(GEN_TRACE)))

define RUN
$(OUTPUT_DIR)/$(mem)_$(cap)_$(cha): $(OUTPUT_DIR)
	mkdir $$@ || :
$(mem).$(cap).$(cha): $(OUTPUT_DIR)/$(mem)_$(cap)_$(cha)/dramsim3.json
$(OUTPUT_DIR)/$(mem)_$(cap)_$(cha)/dramsim3.json: $(CONFIGS_DIR)/$(mem)_$(cap)_$(cha).ini $(TRACE_DIR)/dramsim3_stream_i1_n2000000_rw2000000_c$(cha).trace | $(OUTPUT_DIR)/$(mem)_$(cap)_$(cha)
	./build/dramsim3main $$< -t $(TRACE_DIR)/dramsim3_stream_i1_n2000000_rw2000000_c$(cha).trace -o $(abspath $(OUTPUT_DIR)/$(mem)_$(cap)_$(cha)) -c $(CYC) --host=a
$(mem).$(cap).$(cha).clean:
	rm -rf $(OUTPUT_DIR)/$(mem)_$(cap)_$(cha)
endef
$(foreach mem,$(MEM), \
  $(foreach cap,$(CAP), \
  	$(foreach cha,$(CHA), \
	  $(eval $(RUN)))))