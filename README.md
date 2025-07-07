![image](https://github.com/user-attachments/assets/d2c71a1e-2db5-46e7-957f-86a1a5ff973f)
# RTL-DESIGN-AND-VERIFICATION-OF-RISC-5-FIVE-STAGE-PIPELINE
This project involves the complete RTL design and functional verification of a Reduced Instruction Set Computer (RISC-V) processor. The processor was implemented using SystemVerilog at the Register-Transfer Level (RTL), to the RISC-V ISA specifications. The verification was performed using Universal Verification Methodology (UVM), ensuring modularity, scalability, and reusable verification components.

Key Highlights:
✅ Designed a multi-stage pipelined RISC-V core supporting R, I, S, and B instruction types.

✅ Implemented all key modules including ALU, register file, control unit, hazard detection, and forwarding logic.

✅ Built a UVM-based verification environment, including:

  Transaction-level sequences for various instruction types.

  Functional coverage to ensure instruction diversity and completeness.

  Scoreboard and reference models to check correctness of execution.

✅ Developed a dedicated functional coverage class using SystemVerilog covergroups to monitor Instruction opcode and function field coverage.

✅ Achieved over 95% functional and code coverage, ensuring verification completeness and instruction diversity.

![COVERAGE](https://github.com/user-attachments/assets/22d37e1e-90ca-4fa3-afdf-c03aef4cec5e)

Achieved successful simulation and validation using QuestaSim.
