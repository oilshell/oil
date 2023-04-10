#ifndef MARKSWEEP_HEAP_H
#define MARKSWEEP_HEAP_H

#include <memory>
#include <vector>

#include "mycpp/common.h"
#include "mycpp/gc_obj.h"

class MarkSet {
 public:
  MarkSet() : bits_() {
  }

  // ReInit() must be called at the start of MarkObjects().  Allocate() should
  // keep track of the maximum object ID.
  void ReInit(int max_obj_id) {
    // https://stackoverflow.com/questions/8848575/fastest-way-to-reset-every-value-of-stdvectorint-to-0
    std::fill(bits_.begin(), bits_.end(), 0);
    int max_byte_index = (max_obj_id >> 3) + 1;  // round up
    // log("ReInit max_byte_index %d", max_byte_index);
    bits_.resize(max_byte_index);
  }

  // Called by MarkObjects()
  void Mark(int obj_id) {
    DCHECK(obj_id >= 0);
    // log("obj id %d", obj_id);
    DCHECK(!IsMarked(obj_id));
    int byte_index = obj_id >> 3;  // 8 bits per byte
    int bit_index = obj_id & 0b111;
    // log("byte_index %d %d", byte_index, bit_index);
    bits_[byte_index] |= (1 << bit_index);
  }

  // Called by Sweep()
  bool IsMarked(int obj_id) {
    DCHECK(obj_id >= 0);
    int byte_index = obj_id >> 3;
    int bit_index = obj_id & 0b111;
    return bits_[byte_index] & (1 << bit_index);
  }

  void Debug() {
    int n = bits_.size();
    dprintf(2, "[ ");
    for (int i = 0; i < n; ++i) {
      dprintf(2, "%02x ", bits_[i]);
    }
    dprintf(2, "] (%d bytes) \n", n);
    dprintf(2, "[ ");
    int num_bits = 0;
    for (int i = 0; i < n; ++i) {
      for (int j = 0; j < 8; ++j) {
        int bit = (bits_[i] & (1 << j)) != 0;
        dprintf(2, "%d", bit);
        num_bits += bit;
      }
    }
    dprintf(2, " ] (%d bits set)\n", num_bits);
  }

  std::vector<uint8_t> bits_;  // bit vector indexed by obj_id
};

using Cell = uint8_t[32];

struct Block {
  Cell cells[128];
};

struct Pool {
  ~Pool() {
    log("~Pool()");
    for (Block* block : blocks_) {
      delete block;
    }
  }

  void* Allocate(int* obj_id) {
    int cell_id;
    if (!free_cell_ids_.empty()) {
      cell_id = free_cell_ids_.back();
      free_cell_ids_.pop_back();
      free_[cell_id] = false;
    } else {
      cell_id = next_cell_id_++;
    }
    *obj_id = cell_id;

    size_t block_idx = cell_id / 128;
    size_t cell_idx = cell_id % 128;
    if (block_idx == blocks_.size()) {
      blocks_.push_back(new Block);
      free_.resize(blocks_.size() * 128);
      bytes_allocated_ += sizeof(Block);
    }
    DCHECK(block_idx < blocks_.size());

    num_allocated_++;

    uint8_t* addr = blocks_[block_idx]->cells[cell_idx];
    std::fill(addr, addr + 32, 0);
    return addr;
  }

  void Sweep() {
    for (int cell = 0; cell < next_cell_id_; ++cell) {
      if (!mark_set.IsMarked(cell)) {
        if (!free_[cell]) {
          free_[cell] = true;
          free_cell_ids_.push_back(cell);
        }
      }
    }
  }

  void ReInitMarkSet() {
    mark_set.ReInit(blocks_.size() * 128);
  }

  void LeakMemory() {
    blocks_.clear();
  }

  int num_allocated() {
    return num_allocated_;
  }

  int num_live() {
    return next_cell_id_ - free_cell_ids_.size();
  }

  int64_t bytes_allocated() {
    return bytes_allocated_;
  }

  int num_allocated_ = 0;
  int64_t bytes_allocated_ = 0;

  std::vector<Block*> blocks_;
  MarkSet mark_set;
  int next_cell_id_ = 0;
  std::vector<int> free_cell_ids_;
  std::vector<bool> free_;
};

class MarkSweepHeap {
 public:
  // reserve 32 frames to start
  MarkSweepHeap() {
  }

  void Init();  // use default threshold
  void Init(int gc_threshold);

  void PushRoot(RawObject** p) {
    roots_.push_back(p);
  }

  void PopRoot() {
    roots_.pop_back();
  }

  void RootGlobalVar(void* root) {
    global_roots_.push_back(reinterpret_cast<RawObject*>(root));
  }

  void* Allocate(size_t num_bytes);
  int UnusedObjectId() {
    // Allocate() sets this
    // log("  unused -> %d", obj_id_after_allocate_);
    return obj_id_after_allocate_;
  }

#if 0
  void* Reallocate(void* p, size_t num_bytes);
#endif
  int MaybeCollect();
  int Collect();

  void MaybeMarkAndPush(RawObject* obj);
  void TraceChildren();

  void Sweep();

  void PrintStats(int fd);  // public for testing

  void EagerFree();         // for remaining ASAN clean
  void CleanProcessExit();  // do one last GC so ASAN passes
  void FastProcessExit();   // let the OS clean up

  int num_live() {
    return num_live_ + pool_.num_live();
  }

  bool is_initialized_ = true;  // mark/sweep doesn't need to be initialized

  // Runtime params

  // Threshold is a number of live objects, since we aren't keeping track of
  // total bytes
  int gc_threshold_;

  // Show debug logging
  bool gc_verbose_ = false;

  // Current stats
  int num_live_ = 0;
  // Should we keep track of sizes?
  // int64_t bytes_live_ = 0;

  // Cumulative stats
  int max_survived_ = 0;  // max # live after a collection
  int num_allocated_ = 0;
  int64_t bytes_allocated_ = 0;  // avoid overflow
  int num_gc_points_ = 0;        // manual collection points
  int num_collections_ = 0;
  int num_growths_;
  double max_gc_millis_ = 0.0;
  double total_gc_millis_ = 0.0;

  Pool pool_;

  std::vector<RawObject**> roots_;
  std::vector<RawObject*> global_roots_;

  // Allocate() appends live objects, and Sweep() compacts it
  std::vector<ObjHeader*> live_objs_;
  // Allocate lazily frees these, and Sweep() replenishes it
  std::vector<ObjHeader*> to_free_;

  std::vector<ObjHeader*> gray_stack_;
  MarkSet mark_set_;

  int greatest_obj_id_ = 0;
  int obj_id_after_allocate_ = 0;

 private:
  void DoProcessExit(bool fast_exit);

  DISALLOW_COPY_AND_ASSIGN(MarkSweepHeap);
};

#endif  // MARKSWEEP_HEAP_H
