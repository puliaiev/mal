STEPS = step0_repl step1_read_print

.PHONY: $(STEPS)

$(STEPS):
	swift build --product $@
	ln -s -f .build/debug/$@ $@

clean:
	rm -rf .build/
	rm -f $(STEPS)
