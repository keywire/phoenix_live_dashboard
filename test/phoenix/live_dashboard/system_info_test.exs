defmodule Phoenix.LiveDashboard.SystemInfoTest do
  use ExUnit.Case, async: true
  alias Phoenix.LiveDashboard.SystemInfo

  describe "processes" do
    test "all with limit" do
      {processes, count} = SystemInfo.fetch_processes(node(), "", :memory, :asc, 5000)
      assert Enum.count(processes) == count
      {processes, count} = SystemInfo.fetch_processes(node(), "", :memory, :asc, 1)
      assert Enum.count(processes) == 1
      assert count > 1
    end

    test "all with search" do
      {pids, _count} = SystemInfo.fetch_processes(node(), "user", :memory, :asc, 100)
      assert [[pid, name | _]] = pids
      assert pid == {:pid, Process.whereis(:user)}
      assert name == {:name_or_initial_call, ":user"}
    end

    test "info" do
      {:ok, pid} =
        SystemInfo.fetch_process_info(Process.whereis(:user), [
          :registered_name,
          :message_queue_len
        ])

      assert pid[:registered_name] == :user
      assert is_integer(pid[:message_queue_len])
    end
  end

  describe "ports" do
    test "all with limit" do
      {ports, count} = SystemInfo.fetch_ports(node(), "", :input, :asc, 100)
      assert Enum.count(ports) == count
      {ports, count} = SystemInfo.fetch_ports(node(), "", :input, :asc, 1)
      assert Enum.count(ports) == 1
      assert count > 1
    end

    test "all with search" do
      {ports, _count} = SystemInfo.fetch_ports(node(), "forker", :input, :asc, 100)
      assert [[port, name | _]] = ports
      assert port == {:port, hd(Port.list())}
      assert name == {:name, 'forker'}
    end

    test "info" do
      {:ok, port} = SystemInfo.fetch_port_info(hd(Port.list()), [:name, :connected])
      assert port[:name] == 'forker'
      assert inspect(port[:connected]) == "#PID<0.0.0>"
    end
  end

  describe "ets" do
    test "all with limit" do
      {ets, count} = SystemInfo.fetch_ets(node(), "", :memory, :asc, 100)
      assert Enum.count(ets) == count
      {ets, count} = SystemInfo.fetch_ets(node(), "", :memory, :asc, 1)
      assert Enum.count(ets) == 1
      assert count > 1
    end

    test "all with search" do
      {ets, _count} = SystemInfo.fetch_ets(node(), "ac_tab", :memory, :asc, 100)
      assert [[name | _]] = ets
      assert name == {:name, ":ac_tab"}
    end

    test "info" do
      {:ok, ets} = SystemInfo.fetch_ets_info(node(), :ac_tab)
      assert ets[:name] == :ac_tab
    end
  end
end