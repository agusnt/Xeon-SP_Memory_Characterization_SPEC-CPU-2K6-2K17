#define _GNU_SOURCE 1

#include <asm/unistd.h>
#include <fcntl.h>
#include <linux/perf_event.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <sys/ioctl.h>
#include <sys/wait.h>

#define LEN 100

// Global variable
static int *fd, nfd = -1, go = 0, sample = 0;
FILE *outfd;
static long long *r;

static long perf_event_open(struct perf_event_attr *hw_event, pid_t pid,
    int cpu, int group_fd, unsigned long flags)
{
    int ret;
    ret = syscall(__NR_perf_event_open, hw_event, pid, cpu,
        group_fd, flags);
    return ret;
}

// Handler wake up signal
static void wakeup_handler(int signum, siginfo_t* info, void* context)
{
    go = 1;
    if (signum != SIGUSR1)
    {
        fprintf(stderr, "Wrong signal\n");
        exit(EXIT_FAILURE);
    }
}

// Handler overflow registers
static void perf_event_handler(int signum, siginfo_t* info, void* context)
{
    int i;
    ioctl(info->si_fd, PERF_EVENT_IOC_REFRESH, 1);
    //Test that signal is correct
    if (info->si_code == POLL_HUP){
        //Read all counters and save into file
        read(fd[0], r, sizeof(long long) * (nfd + 1));
        for (i = 1; i <= r[0]; i++) fprintf(outfd, "%lld ", r[i]);
        fprintf(outfd, "\n");
    }
}

// Initialize signal struct
int initSig(struct sigaction *sa)
{
    //Configure signal hanlder
    memset(sa, 0, sizeof(struct sigaction));
    sa->sa_sigaction = perf_event_handler;
    sa->sa_flags = SA_SIGINFO | SA_RESTART;

    //Setup signal handler
    if (sigaction(SIGIO, sa, NULL) < 0)
    {
        fprintf(stderr, "Error setting up signal handler\n");
        perror("sigaction");
        return -1;
    }
    return 0;
}

// Init WakeUp Signal
int initWakeSig(struct sigaction *sa)
{
    //Configure signal hanlder
    memset(sa, 0, sizeof(struct sigaction));
    sa->sa_sigaction = wakeup_handler;
    sa->sa_flags = SA_SIGINFO | SA_RESTART;

    //Setup signal handler
    if (sigaction(SIGUSR1, sa, NULL) < 0)
    {
        fprintf(stderr, "Error setting up signal handler\n");
        perror("sigaction");
        return -1;
    }
    return 0; 
}

void perfStruct (struct perf_event_attr *pe, char leader, int type, int config)
{
        memset(pe, 0, sizeof(struct perf_event_attr));
        pe->size = sizeof(struct perf_event_attr);
        pe->disabled = 1;
        //Exclude kernel and hipervisor from being measure
        pe->exclude_kernel = 1;
        pe->exclude_hv = 1;
        if (leader)
        {
            pe->read_format = PERF_FORMAT_GROUP;
            if (sample != 0) pe->sample_period = sample;
        }
        pe->type = type;
        pe->config = config;
}

// Parse counter program options
int counterProgram(int *out, char *in)
{
    if (strcmp(in, "PERF_COUNT_HW_CPU_CYCLES") == 0)
    {
        *out = PERF_TYPE_HARDWARE;
        return PERF_COUNT_HW_CPU_CYCLES;
    }
    else if (strcmp(in, "PERF_COUNT_HW_INSTRUCTIONS") == 0)
    {
        *out = PERF_TYPE_HARDWARE;
        return PERF_COUNT_HW_INSTRUCTIONS;
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_REFERENCES") == 0)
    {
        *out = PERF_TYPE_HARDWARE;
        return PERF_COUNT_HW_CACHE_REFERENCES;
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_MISSES") == 0)
    {
        *out = PERF_TYPE_HARDWARE;
        return PERF_COUNT_HW_CACHE_MISSES;
    }
    else if (strcmp(in, "PERF_COUNT_HW_BRANCH_INSTRUCTIONS") == 0)
    {
        *out = PERF_TYPE_HARDWARE;
        return PERF_COUNT_HW_BRANCH_INSTRUCTIONS;
    }
    else if (strcmp(in, "PERF_COUNT_HW_BRANCH_MISSES") == 0)
    {
        *out = PERF_TYPE_HARDWARE;
        return PERF_COUNT_HW_BRANCH_MISSES;
    }
    else if (strcmp(in, "PERF_COUNT_HW_BUS_CYCLES") == 0)
    {
        *out = PERF_TYPE_HARDWARE;
        return PERF_COUNT_HW_BUS_CYCLES;
    }
    else if (strcmp(in, "PERF_COUNT_HW_STALLED_CYCLES_FRONTEND") == 0)
    {
        *out = PERF_TYPE_HARDWARE;
        return PERF_COUNT_HW_STALLED_CYCLES_FRONTEND;
    }
    else if (strcmp(in, "PERF_COUNT_HW_STALLED_CYCLES_BACKEND") == 0)
    {
        *out = PERF_TYPE_HARDWARE;
        return PERF_COUNT_HW_STALLED_CYCLES_BACKEND;
    }
    else if (strcmp(in, "PERF_COUNT_HW_CPU_CYCLES") == 0)
    {
        *out = PERF_TYPE_HARDWARE;
        return PERF_COUNT_HW_CPU_CYCLES;
    }
    else if (strcmp(in, "PERF_COUNT_SW_CPU_CLOCK") == 0)
    {
        *out = PERF_TYPE_SOFTWARE;
        return PERF_COUNT_SW_CPU_CLOCK;
    }
    else if (strcmp(in, "PERF_COUNT_SW_TASK_CLOCK") == 0)
    {
        *out = PERF_TYPE_SOFTWARE;
        return PERF_COUNT_SW_TASK_CLOCK;
    }
    else if (strcmp(in, "PERF_COUNT_SW_PAGE_FAULTS") == 0)
    {
        *out = PERF_TYPE_SOFTWARE;
        return PERF_COUNT_SW_PAGE_FAULTS;
    }
    else if (strcmp(in, "PERF_COUNT_SW_CONTEXT_SWITCHES") == 0)
    {
        *out = PERF_TYPE_SOFTWARE;
        return PERF_COUNT_SW_CONTEXT_SWITCHES;
    }
    else if (strcmp(in, "PERF_COUNT_SW_CPU_MIGRATIONS") == 0)
    {
        *out = PERF_TYPE_SOFTWARE;
        return PERF_COUNT_SW_CPU_MIGRATIONS;
    }
    else if (strcmp(in, "PERF_COUNT_SW_PAGE_FAULTS_MIN") == 0)
    {
        *out = PERF_TYPE_SOFTWARE;
        return PERF_COUNT_SW_PAGE_FAULTS_MIN;
    }
    else if (strcmp(in, "PERF_COUNT_SW_PAGE_FAULTS_MAJ") == 0)
    {
        *out = PERF_TYPE_SOFTWARE;
        return PERF_COUNT_SW_PAGE_FAULTS_MAJ;
    }
    else if (strcmp(in, "PERF_COUNT_SW_ALIGNMENT_FAULTS") == 0)
    {
        *out = PERF_TYPE_SOFTWARE;
        return PERF_COUNT_SW_ALIGNMENT_FAULTS;
    }
    else if (strcmp(in, "PERF_COUNT_SW_EMULATION_FAULTS") == 0)
    {
        *out = PERF_TYPE_SOFTWARE;
        return PERF_COUNT_SW_EMULATION_FAULTS;
    }
    else if (strcmp(in, "PERF_COUNT_SW_DUMMY") == 0)
    {
        *out = PERF_TYPE_SOFTWARE;
        return PERF_COUNT_SW_DUMMY;
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_L1D_ACCESS_R") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_L1D)
            | (PERF_COUNT_HW_CACHE_OP_READ << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_ACCESS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_L1I_ACCESS_R") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_L1I)
            | (PERF_COUNT_HW_CACHE_OP_READ << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_ACCESS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_LL_ACCESS_R") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_LL)
            | (PERF_COUNT_HW_CACHE_OP_READ << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_ACCESS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_DTLB_ACCESS_R") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_DTLB)
            | (PERF_COUNT_HW_CACHE_OP_READ << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_ACCESS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_ITLB_ACCESS_R") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_ITLB)
            | (PERF_COUNT_HW_CACHE_OP_READ << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_ACCESS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_BPU_ACCESS_R") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_BPU)
            | (PERF_COUNT_HW_CACHE_OP_READ << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_ACCESS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_NODE_ACCESS_R") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_NODE)
            | (PERF_COUNT_HW_CACHE_OP_READ << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_ACCESS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_L1D_ACCESS_W") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_L1D)
            | (PERF_COUNT_HW_CACHE_OP_WRITE << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_ACCESS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_L1I_ACCESS_W") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_L1I)
            | (PERF_COUNT_HW_CACHE_OP_WRITE << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_ACCESS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_LL_ACCESS_W") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_LL)
            | (PERF_COUNT_HW_CACHE_OP_WRITE << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_ACCESS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_DTLB_ACCESS_W") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_DTLB)
            | (PERF_COUNT_HW_CACHE_OP_WRITE << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_ACCESS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_ITLB_ACCESS_W") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_ITLB)
            | (PERF_COUNT_HW_CACHE_OP_WRITE << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_ACCESS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_BPU_ACCESS_W") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_BPU)
            | (PERF_COUNT_HW_CACHE_OP_WRITE << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_ACCESS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_NODE_ACCESS_W") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_NODE)
            | (PERF_COUNT_HW_CACHE_OP_WRITE << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_ACCESS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_L1D_MISS_R") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_L1D)
            | (PERF_COUNT_HW_CACHE_OP_READ << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_MISS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_L1I_MISS_R") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_L1I)
            | (PERF_COUNT_HW_CACHE_OP_READ << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_MISS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_LL_MISS_R") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_LL)
            | (PERF_COUNT_HW_CACHE_OP_READ << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_MISS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_DTLB_MISS_R") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_DTLB)
            | (PERF_COUNT_HW_CACHE_OP_READ << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_MISS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_ITLB_MISS_R") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_ITLB)
            | (PERF_COUNT_HW_CACHE_OP_READ << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_MISS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_BPU_MISS_R") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_BPU)
            | (PERF_COUNT_HW_CACHE_OP_READ << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_MISS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_NODE_MISS_R") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_NODE)
            | (PERF_COUNT_HW_CACHE_OP_READ << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_MISS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_L1D_MISS_W") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_L1D)
            | (PERF_COUNT_HW_CACHE_OP_WRITE << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_MISS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_L1I_MISS_W") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_L1I)
            | (PERF_COUNT_HW_CACHE_OP_WRITE << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_MISS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_LL_MISS_W") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_LL)
            | (PERF_COUNT_HW_CACHE_OP_WRITE << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_MISS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_DTLB_MISS_W") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_DTLB)
            | (PERF_COUNT_HW_CACHE_OP_WRITE << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_MISS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_ITLB_MISS_W") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_ITLB)
            | (PERF_COUNT_HW_CACHE_OP_WRITE << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_MISS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_BPU_MISS_W") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_BPU)
            | (PERF_COUNT_HW_CACHE_OP_WRITE << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_MISS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_NODE_MISS_W") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_NODE)
            | (PERF_COUNT_HW_CACHE_OP_WRITE << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_MISS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_L1D_ACCESS_P") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_L1D)
            | (PERF_COUNT_HW_CACHE_OP_PREFETCH << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_ACCESS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_L1I_ACCESS_P") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_L1I)
            | (PERF_COUNT_HW_CACHE_OP_PREFETCH << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_ACCESS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_LL_ACCESS_P") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_LL)
            | (PERF_COUNT_HW_CACHE_OP_PREFETCH << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_ACCESS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_DTLB_ACCESS_P") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_DTLB)
            | (PERF_COUNT_HW_CACHE_OP_PREFETCH << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_ACCESS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_ITLB_ACCESS_P") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_ITLB)
            | (PERF_COUNT_HW_CACHE_OP_PREFETCH << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_ACCESS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_BPU_ACCESS_P") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_BPU)
            | (PERF_COUNT_HW_CACHE_OP_PREFETCH << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_ACCESS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_NODE_ACCESS_P") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_NODE)
            | (PERF_COUNT_HW_CACHE_OP_PREFETCH << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_ACCESS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_L1D_MISS_P") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_L1D)
            | (PERF_COUNT_HW_CACHE_OP_PREFETCH << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_MISS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_L1I_MISS_P") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_L1I)
            | (PERF_COUNT_HW_CACHE_OP_PREFETCH << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_MISS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_LL_MISS_P") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_LL)
            | (PERF_COUNT_HW_CACHE_OP_PREFETCH << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_MISS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_DTLB_MISS_P") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_DTLB)
            | (PERF_COUNT_HW_CACHE_OP_PREFETCH << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_MISS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_ITLB_MISS_P") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_ITLB)
            | (PERF_COUNT_HW_CACHE_OP_PREFETCH << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_MISS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_BPU_MISS_P") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_BPU)
            | (PERF_COUNT_HW_CACHE_OP_PREFETCH << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_MISS << 16);
    }
    else if (strcmp(in, "PERF_COUNT_HW_CACHE_NODE_MISS_P") == 0)
    {
        *out = PERF_TYPE_HW_CACHE;
        return (PERF_COUNT_HW_CACHE_NODE)
            | (PERF_COUNT_HW_CACHE_OP_PREFETCH << 8)
            | (PERF_COUNT_HW_CACHE_RESULT_MISS << 16);
    }
    else return -1;
}

// Prints all events options
void printEvents()
{

    fprintf(stdout, "Events list (since Linux 3.1)\n");
    fprintf(stdout, "\n");

    fprintf(stdout, "PERF_COUNT_HW_CPU_CYCLES -- Total cycles (Affected by frequency scaling)\n");
    fprintf(stdout, "PERF_COUNT_HW_INSTRUCTIONS -- Retired instructions\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_REFERENCES -- Cache access (Usually LLC)\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_MISSES -- Cache misses (Usually LLC)\n");
    fprintf(stdout, "PERF_COUNT_HW_BRANCH_INSTRUCTIONS -- Retired branch instructions\n");
    fprintf(stdout, "PERF_COUNT_HW_BRANCH_MISSES -- Mispredicted branch instructions\n");
    fprintf(stdout, "PERF_COUNT_HW_BUS_CYCLES -- Bus cycles\n");
    fprintf(stdout, "PERF_COUNT_HW_STALLED_CYCLES_FRONTEND -- Stalled cycles during issue\n");
    fprintf(stdout, "PERF_COUNT_HW_STALLED_CYCLES_BACKEND -- Stalled cycles during retirement\n");
    fprintf(stdout, "PERF_COUNT_HW_CPU_CYCLES -- Total cycles\n");
    fprintf(stdout, "PERF_COUNT_SW_CPU_CLOCK -- CPU clock\n");
    fprintf(stdout, "PERF_COUNT_SW_TASK_CLOCK -- Clock count specific to the task that is running\n");
    fprintf(stdout, "PERF_COUNT_SW_PAGE_FAULTS -- Number of page faults\n");
    fprintf(stdout, "PERF_COUNT_SW_CONTEXT_SWITCHES -- Number of context switches\n");
    fprintf(stdout, "PERF_COUNT_SW_CPU_MIGRATIONS -- Number of times the process has to migrated to a new CPU\n");
    fprintf(stdout, "PERF_COUNT_SW_PAGE_FAULTS_MIN -- Number of minor page faults\n");
    fprintf(stdout, "PERF_COUNT_SW_PAGE_FAULTS_MAJ -- Number of major page faults\n");
    fprintf(stdout, "PERF_COUNT_SW_ALIGNMENT_FAULTS -- Number of alignment faults\n");
    fprintf(stdout, "PERF_COUNT_SW_EMULATION_FAULTS -- Number of emulation faults\n");
    fprintf(stdout, "PERF_COUNT_SW_DUMMY -- Placeholder event that counts nothing\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_L1D_ACCESS_R -- Read accesses to L1 data cache\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_L1I_ACCESS_R -- Read accesses to L1 instruction cache\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_LL_ACCESS_R -- Read accesses to LLC cache\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_DTLB_ACCESS_R -- Read access to Data TLB\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_ITLB_ACCESS_R -- Read access to Instruction TLB\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_BPU_ACCESS_R -- Read accesses to branch prediction Unit\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_NODE_ACCESS_R -- Read accesses to local memory\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_L1D_ACCESS_W -- Write accesses to L1 data cache\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_L1I_ACCESS_W -- Write accesses to L1 instruction cache\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_LL_ACCESS_W -- Write accesses to LLC cache\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_DTLB_ACCESS_W -- Write accesses to Data TLB\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_ITLB_ACCESS_W -- Write accesses to Instruction TLB\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_BPU_ACCESS_W -- Write accesses to branch prediction Unit\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_NODE_ACCESS_W -- Write accesses to local memory\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_L1D_MISS_R -- Read misses to L1 data cache\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_L1I_MISS_R -- Read misses to L1 instruction cache\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_LL_MISS_R -- Read misses to LLC cache\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_DTLB_MISS_R -- Read misses to Data TLB\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_ITLB_MISS_R -- Read misses to Istruction TLB\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_BPU_MISS_R -- Read misses to branch prediction\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_NODE_MISS_R -- Read misses to local memory\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_L1D_MISS_W -- Write misses to L1 data cache\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_L1I_MISS_W -- Write misses to L1 instruction cache\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_LL_MISS_W -- Write misses to LLC cache\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_DTLB_MISS_W -- Write misses to Data TLB\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_ITLB_MISS_W -- Write misses to Instruction TLB\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_BPU_MISS_W -- Write misses to branch predicition Unit\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_NODE_MISS_W -- Write miesses to local memory\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_L1D_ACCESS_P -- Prefetch accesses to L1 data cache\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_L1I_ACCESS_P -- Prefetch accesses to L1 instruction cache\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_LL_ACCESS_P -- Prefetch accesses to LLC cache\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_DTLB_ACCESS_P -- Prefetch accesses to Data TLB\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_ITLB_ACCESS_P -- Prefecth accesses to Instruction TLB\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_BPU_ACCESS_P -- Prefetch accesses to branch prediction unit\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_NODE_ACCESS_P -- Prefetch accesses to local memory\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_L1D_MISS_P -- Prefecth misses to L1 data cache\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_L1I_MISS_P -- Prefetch misses to L1 instruction cache\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_LL_MISS_P -- Prefetch misses to LLC cache\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_DTLB_MISS_P -- Prefetch misses to Data TLB\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_ITLB_MISS_P -- Prefetch misses to Instruction TLB\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_BPU_MISS_P -- Prefetch misses to branch prediction unit\n");
    fprintf(stdout, "PERF_COUNT_HW_CACHE_NODE_MISS_P -- Prefetch misses to local memory\n");
}

// Measure HW counters
void measure(int argc, char **argv, char (*event)[LEN], int size, int raw)
{
    int i, returnStatus, type, config;
    sigset_t sigmask, oldmask;
    pid_t pid;
    struct perf_event_attr pe[nfd];
    struct sigaction sa, wake;

    // Block SIGUSR1, for safety reasons
    sigemptyset(&sigmask);
    sigaddset(&sigmask, SIGUSR1);
    sigfillset(&oldmask);

    if ((pid = fork()) == 0)
    {
        // Wait until parent process is ready to measure
        sigprocmask(SIG_BLOCK, &sigmask, &oldmask);
        if (kill(getppid(), SIGUSR1) == -1)
        {
            fprintf(stderr, "Can't wakup child process\n");
            exit(EXIT_FAILURE);
        }
        if (initWakeSig(&wake) == -1) exit(EXIT_FAILURE);
        if (!go) sigsuspend(&oldmask);
        // Launch extern program
        execvp(argv[0], argv);
        // Child should never reach this exit
        exit(EXIT_FAILURE);
    } else if (pid < 1)
    {
        fprintf(stderr, "Can't create a childre\n");
        exit(EXIT_FAILURE);
    }

    // Wait until child process is ready (parent process always have to
    // execute after child process)
    sigprocmask(SIG_BLOCK, &sigmask, &oldmask);
    if (initWakeSig(&wake) == -1) exit(EXIT_FAILURE);
    if (!go) sigsuspend(&oldmask);
    sigprocmask(SIG_UNBLOCK, &sigmask, NULL);

    //TODO: improve signal and blocking between parent and child process in
    //order to avoid use sleep (THIS DON'T GUARANTEE 100% THAT CHILDREN FINISHES
    //ITS SIGNAL COMUNICATION)
    sleep(1);

    // Init signal for overflow
    if (initSig(&sa) == -1) exit(EXIT_FAILURE);
    // Init structs for Perf
    for (i = 0; i < nfd; i++)
    {
        // Print options
        fprintf(outfd, "#%s ", event[i]);

        // Events are defined by operating system
        if (!raw) config = counterProgram(&type, event[i]);
        // Events are raw
        else 
        {
            type = PERF_TYPE_RAW;
            config = (int) strtol(event[i], NULL, 16);
        }

        if (config == -1)
        {
            fprintf(stderr, "Wrong Event\n");
            exit(EXIT_FAILURE);
        }
        // First event is the leader
        if (!i) perfStruct(&pe[i], 1, type, config);
        else perfStruct(&pe[i], 0, type, config);
    }
    fprintf(outfd, "\n");

    // Init Perf Events
    if((fd[0] = perf_event_open(&pe[0], pid, -1, -1, PERF_FLAG_FD_CLOEXEC)) == -1)
    {
        fprintf(stderr, "Error opening leader %llx\n", pe[0].config);
        fprintf(stderr, "ERRNO: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }
    for (i = 1; i < nfd; i++)
    {
        if ((fd[i] = perf_event_open(&pe[i], pid, -1, fd[0], 0)) == -1)
        {
            fprintf(stderr, "Error opening leader %llx\n", pe[i].config);
            fprintf(stderr, "ERRNO: %s\n", strerror(errno));
            exit(EXIT_FAILURE);
        }
    }

    //Setup event handler for overflow signals
    fcntl(fd[0], F_SETFL, O_NONBLOCK | O_ASYNC);
    fcntl(fd[0], F_SETSIG, SIGIO);
    fcntl(fd[0], F_SETOWN, getpid());

    for (i = 1; i < nfd; i++)
    {
        ioctl(fd[i], PERF_EVENT_IOC_RESET, 0);
        ioctl(fd[i], PERF_EVENT_IOC_ENABLE, 0);
    }
    ioctl(fd[0], PERF_EVENT_IOC_RESET, 0);
    ioctl(fd[0], PERF_EVENT_IOC_ENABLE, 0);
    ioctl(fd[0], PERF_EVENT_IOC_REFRESH, 1);

    //Send signal to extern process and wait until child end (WE ARE MEASURING!!)
    if (kill(pid, SIGUSR1) == -1) fprintf(stderr, "Can't wake up child process\n");
    else 
    {
        wait(&returnStatus);
        if (returnStatus != 0) 
        {
            fprintf(stderr, "Program did not finish normally: %d, ERRNO: %s\n", 
                returnStatus, strerror(errno));
        }
    }
    
    for (i = 0; i < nfd; i++) ioctl(fd[i], PERF_EVENT_IOC_DISABLE, 0);

    // Print last values
    read(fd[0], r, sizeof(long long) * (nfd + 1));
    for (i = 1; i <= r[0]; i++) fprintf(outfd, "%lld ", r[i]);
    fprintf(outfd, "\n");

    // Close file descriptors
    for (i = 0; i < nfd; i++) close(fd[i]);
}

int main(int argc, char **argv)
{
    int c, i, maxC = 0, raw = 0;
    char counter[LEN][LEN];

    // Parse program arguments
    while ((c = getopt(argc, argv, "ln:o:c:s:rh")) != -1)
    {
        switch(c)
        {
            case 'l':
                printEvents();
                goto exit;
            case 'o':
                outfd = fopen(optarg, "w");
                break;
            case 'n':
                if ((nfd = atoi(optarg)) > 4) 
                    fprintf(stderr, "Warning: more than 4 events is probably "
                        "not supported, depends on kernel version and CPU\n");
                break;
            case 'c':
                optind--;
                for (i = 0; optind < argc && *argv[optind] != '-'; optind++, i++)
                    strcpy(counter[i], argv[optind]);
                maxC = i;
                break;
            case 'h':
                fprintf(stdout, "./main -n [number of events] -o [output file] "
                    "-c [Counters] -s [Samples] [-r] -- Program args\n");
                goto exit;
                break;
            case 's':
                if ((sample = atoi(optarg)) < 1)
                    fprintf(stdout, "Sample must be greater than 0\n");
                break;
            case 'r':
                fprintf(stdout, "WARNING: I don't test if raw event is correct\n");
                raw = 1;
                break;
        }
    }
    if (strcmp(argv[optind - 1], "--") != 0)
    {
        fprintf(stderr, "./main -n [number of events] -o [output file] "
                    "-c [Counters] -s [Samples] [-r] -- Program args\n");
        goto exit;
    }

    // Test if all variables are set
    if (nfd == -1 || outfd == NULL || maxC == 0)
    {
        fprintf(stderr, "./main -n [number of events] -o [output file] "
                    "-c [Counters] -s [Samples] [-r] -- Program args\n");
        goto exit;
    }

    // Allocate file descriptos
    fd = malloc(sizeof(int) * nfd);
    // Allocate struct for reading output
    r = malloc(sizeof(long long) * (nfd + 1));
    // Print basic information
    measure(argc - optind, &argv[optind], counter, maxC, raw);
exit:
    if (outfd != NULL) fclose(outfd);
}
